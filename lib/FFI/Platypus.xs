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
  int i,n, perl_arg_index, perl_type_index;
  SV *arg;
  ffi_pl_result result;
  ffi_pl_arguments arguments;
  SV *freeme = NULL; /* scratch space for custom perl handlers */
#ifndef FFI_PL_PROBE_RUNTIMESIZEDARRAYS
  void **argument_pointers;
  ffi_pl_argument *argument_slots;
#endif
  
  dVAR; dXSARGS;
  
  self = (ffi_pl_function*) CvXSUBANY(cv).any_ptr;

#define EXTRA_ARGS 0
#include "ffi_platypus_call.h"
}

/* this code is shared between implementations */
static ffi_pl_function *
ffi_pl_make_method(ffi_pl_cached_method *cached, void **selfp, void (**bodyp)(void *), SV **first_argument, SV *object)
{
  dVAR;
  dSP;
  int count;

  SV *body_object;
  SV *function_object;

  void (*body)(void *);
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
  body_object = POPs;
  function_object = POPs;

  if(!function_object || !SvROK(function_object)
  || !sv_derived_from(function_object, "FFI::Platypus::Function")
  || !body_object || !SvIOK(body_object))
  {
    croak("make_attach_method failed");
  }

  body = INT2PTR(void (*)(void *), SvIV(body_object));
  function = INT2PTR(ffi_pl_function *, SvIV(SvRV(function_object)));

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

/* this code is specific to one implementation */
static void ffi_pl_method_call_body(void *self_ptr)
{
  ffi_pl_function *self;
  char *buffer;
  size_t buffer_size;
  int i,n, perl_arg_index, perl_type_index;
  SV *arg;
  ffi_pl_result result;
  ffi_pl_arguments arguments;
  SV *first_argument = NULL;
  SV *freeme = NULL;

  dVAR; dXSARGS;

  self = self_ptr;

#define EXTRA_ARGS (0)
#include "ffi_platypus_call.h"
}

/* this code is shared between implementations. */
XS(ffi_pl_method_call)
{
  ffi_pl_cached_method *cached;
  void (*body)(void *self);
  void *self;
  SV *first_argument = NULL;

  dVAR; dXSARGS;

  if(items == 0)
  {
    croak("cannot call an object method without arguments");
  }

  cached = (ffi_pl_cached_method *) CvXSUBANY(cv).any_ptr;
  body = cached->body;
  self = cached->function;

  if(cached->weakref
  && SvROK(ST(0))
  && SvROK(cached->weakref)
  && (SvRV(cached->weakref) == SvRV(ST(0)))) {
    /* the common case: fall through to the calling code */
    first_argument = cached->argument;
  }
  else if(cached->weakref
       && SvPOK(ST(0))
       && SvPOK(cached->weakref)
       && sv_eq(cached->weakref, ST(0)))
  {
    /* slightly slower: class method. Also fall through. */
    first_argument = cached->argument;
  }
  else
  {
    /* the slow case. Go back to Perl to retrieve our method. */
    ffi_pl_make_method(cached, &self, &body, &first_argument, ST(0));
    SPAGAIN;

    if(!self) {
      croak("could not generate a method on demand");
    }
  }

  /* we manipulate the Perl stack to make the first argument go away
   * if required, and replace it otherwise. */
  if(first_argument == NULL)
    MARK++;
  else
    ST(0) = first_argument;

  PUTBACK;
  PUSHMARK(MARK);

  body(self);
}

/*
 * -1 until we have checked
 *  0 tried, not there
 *  1 tried, is there
 */
int have_math_longdouble = -1;  /* Math::LongDouble */
int have_math_complex    = -1;  /* Math::Complex    */

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


INCLUDE: ../../xs/dl.xs
INCLUDE: ../../xs/Type.xs
INCLUDE: ../../xs/Function.xs
INCLUDE: ../../xs/Declare.xs
INCLUDE: ../../xs/ClosureData.xs
INCLUDE: ../../xs/API.xs
INCLUDE: ../../xs/ABI.xs
INCLUDE: ../../xs/Record.xs
