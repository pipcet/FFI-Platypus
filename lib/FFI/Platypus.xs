#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"

#include "ffi_platypus.h"
#include "ffi_platypus_guts.h"

#ifndef HAVE_IV_IS_64
#include "perl_math_int64.h"
#endif

ffi_pl_arguments *current_argv = NULL;

void *cast0(void)
{
  return NULL;
}

void *cast1(void *value)
{
  return value;
}

XS(ffi_pl_sub_call)
{
  ffi_pl_function *self;
  char *buffer;
  size_t buffer_size;
  int i,n, perl_arg_index;
  SV *arg;
  ffi_pl_result result;
  ffi_pl_arguments *arguments;
  void **argument_pointers;
  
  dVAR; dXSARGS;
  
  self = (ffi_pl_function*) CvXSUBANY(cv).any_ptr;

#define EXTRA_ARGS 0
#include "ffi_platypus_call.h"
}

/*
 * -1 until we have checked
 *  0 tried, not there
 *  1 tried, is there
 */
int have_math_longdouble = -1;  /* Math::LongDouble */
int have_math_complex    = -1;  /* Math::Complex    */

#include "ffi_platypus_rtypes.h"
#include "ffi_platypus_rtypes_guts.h"

extern XS(ffi_pl_rtypes_sub_call);
XS(ffi_pl_rtypes_sub_call_old)
{
  dVAR; dXSARGS;
  ffi_pl_rtypes_function *self;
  int i,n, perl_arg_index, perl_type_index;
  SV *arg;
  ffi_pl_result result;
  ffi_pl_rtypes_arguments arguments;
  SV *freeme = NULL; /* scratch space for custom perl handlers */
#ifndef FFI_PL_PROBE_RUNTIMESIZEDARRAYS
  void **argument_pointers;
  ffi_pl_argument *argument_slots;
#endif
  
  {
  dXSTARG;
  
  self = (ffi_pl_rtypes_function*) CvXSUBANY(cv).any_ptr;

#define EXTRA_ARGS 0
#include "ffi_platypus_rtypes_call.h"
  }
}

/* this code is shared between implementations */
void *
ffi_pl_make_method(ffi_pl_cached_method *cached, void **selfp, void (**bodyp)(pTHX_ void *, int), SV **first_argument, SV *object)
{
  dVAR;
  dSP;
  int count;

  SV *body_object;
  SV *function_object;

  void (*body)(pTHX_ void *, int);
  void *function;

  ENTER;
  SAVETMPS;
  PUSHMARK(SP);
  XPUSHs(object);
  XPUSHs(newRV_noinc((SV*)cached->other_methods));
  PUTBACK;

  count = call_pv("FFI::Platypus::_make_attach_method", G_ARRAY);
  SPAGAIN;

  if(count < 2 || count > 3)
  {
    croak("make_attach_method failed");
  }

  if(count == 3)
  {
    *first_argument = SvREFCNT_inc(POPs);
  }
  function_object = POPs;
  body_object = POPs;

  if(!body_object || !SvIOK(body_object))
  {
    croak("make_attach_method failed");
  }

  body = INT2PTR(void (*)(pTHX_ void *, int), SvIV(body_object));
  function = INT2PTR(ffi_pl_rtypes_function *, SvIV(SvRV(function_object)));

  *bodyp = body;
  *selfp = function;

  cached->body = body;
  cached->function = function;
  SvREFCNT_dec(cached->argument);
  cached->argument = *first_argument;

  if(SvROK(object))
  {
    cached->weakref = newRV_inc(SvRV(object));
    sv_rvweaken(cached->weakref);
  }
  else if(SvPOK(object))
  {
    cached->weakref = SvREFCNT_inc(object);
  }

  PUTBACK;
  FREETMPS;
  LEAVE;

  return function;
}

XS(ffi_pl_method_call);

MODULE = FFI::Platypus PACKAGE = FFI::Platypus

BOOT:
#ifndef HAVE_IV_IS_64

    PERL_MATH_INT64_LOAD_OR_CROAK;
#endif

int
_have_math_longdouble(value = -2)
    int value
  CODE:
    if(value != -2)
      have_math_longdouble = value;
    RETVAL = have_math_longdouble;
  OUTPUT:
    RETVAL

int
_have_math_complex(value = -2)
    int value
  CODE:
    if(value != -2)
      have_math_complex = value;
    RETVAL = have_math_complex;
  OUTPUT:
    RETVAL

int
_have_type(name)
    const char *name
  CODE:
    RETVAL = !strcmp(name, "string") || ffi_pl_name_to_type(name) != NULL;
  OUTPUT:
    RETVAL

BOOT:
#ifndef HAVE_IV_IS_64
    PERL_MATH_INT64_LOAD_OR_CROAK;
#endif

SV *
_get_other_methods(ffi, perl_name)
    SV *ffi
    const char *perl_name
  PREINIT:
    CV *cv;
    ffi_pl_cached_method *method;
    SV *value;
  CODE:
    cv = get_cv(perl_name, 0);

    if(cv == NULL
    || CvXSUB(cv) != ffi_pl_method_call)
      RETVAL = NULL;
    else
    {
      method = CvXSUBANY(cv).any_ptr;

      RETVAL = newRV_inc((SV*)method->other_methods);
    }
  OUTPUT:
    RETVAL

void
_attach_body_data(ffi, object, key, argument, drop_first_argument, perl_name, path_name, proto, body, data)
    SV *ffi
    SV *object
    SV *key
    SV *argument
    int drop_first_argument
    const char *perl_name
    ffi_pl_string path_name
    ffi_pl_string proto
    SV *body
    SV *data
  PREINIT:
    CV *cv;
    ffi_pl_cached_method *method;
    SV *value;
  CODE:
    cv = get_cv(perl_name, 0);

    if(cv == NULL
    || CvXSUB(cv) != ffi_pl_method_call)
    {
      Newx(method, 1, ffi_pl_cached_method);
      method->body = NULL;
      method->function = NULL;
      method->weakref = NULL; /* create on first call */
      method->argument = NULL;
      method->other_methods = newHV();

      if(proto == NULL)
	cv = newXS(perl_name, ffi_pl_method_call, path_name);
      else
      {
	/*
	 * this ifdef is needed for Perl 5.8.8 support.
	 * once we don't need to support 5.8.8 we can
	 * remove this workaround (the ndef'd branch)
	 */
#ifdef newXS_flags
	cv = newXSproto(perl_name, ffi_pl_method_call, path_name, proto);
#else
	newXSproto(perl_name, ffi_pl_method_call, path_name, proto);
	cv = get_cv(perl_name,0);
#endif
      }
      CvXSUBANY(cv).any_ptr = (void *) method;
      /*
       * No coresponding decrement !!
       * once attached, you can never free the function object, or the FFI::Platypus
       * it was created from.
       */
      SvREFCNT_inc(ffi);
    }
    else
    {
      /*
       * Ideally, we should check here that the prototype of the
       * existing CV matches the one we request. However, I don't know
       * how to do that.
       */
      method = CvXSUBANY(cv).any_ptr;
    }

    value = newRV_noinc((SV*)newHV());
    hv_store((HV*)SvRV(value), "ffi", strlen("ffi"), SvREFCNT_inc(ffi), 0);
    hv_store((HV*)SvRV(value), "function", strlen("function"), SvREFCNT_inc(data), 0);
    hv_store((HV*)SvRV(value), "body", strlen("body"), SvREFCNT_inc(body), 0);
    if(SvROK(object))
    {
      hv_store((HV*)SvRV(value), "weakref", strlen("weakref"), sv_rvweaken(newSVsv(object)), 0);
    }
    if(!drop_first_argument)
    {
      hv_store((HV*)SvRV(value), "argument", strlen("argument"), SvREFCNT_inc(argument), 0);
    }

    hv_store_ent(method->other_methods, key, value, 0);

INCLUDE: ../../xs/Lazy/Function.xs
INCLUDE: ../../xs/dl.xs
INCLUDE: ../../xs/Declare.xs
INCLUDE: ../../xs/API.xs
INCLUDE: ../../xs/ABI.xs
INCLUDE: ../../xs/Libffi.xs
INCLUDE: ../../xs/RTypes.xs
