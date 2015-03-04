#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"

#include "impl/libffi-perl/ffi_platypus.h"
#include "impl/libffi-perl/ffi_platypus_guts.h"

#ifndef HAVE_IV_IS_64
#include "perl_math_int64.h"
#endif

ffi_pl_ffiperl_arguments *current_argv = NULL;

void *cast0(void)
{
  return NULL;
}

void *cast1(void *value)
{
  return value;
}

ffi_pl_ffiperl_type *SV2ffi_pl_ffiperl_type(void *svraw)
{
  SV *sv = svraw;

  if(sv_isobject(sv) && sv_derived_from(sv, "FFI::Platypus::Type")) {
    HV *hv = (HV*)SvRV(sv);
    SV **svp = hv_fetch(hv, "ffi_pl_type", strlen("ffi_pl_type"), 0);
    if (svp == NULL)
      Perl_croak(aTHX_ "ret is missing the ffi_pl_type hash entry");
    return INT2PTR(ffi_pl_ffiperl_type *, SvIV((SV*)SvRV(*svp)));
  } else
    Perl_croak(aTHX_ "ret is not of type FFI::Platypus::Type");
}

ffi_pl_ffiperl_type *SV2ffi_pl_ffiperl_type_nocheck(void *svraw)
{
  SV *sv = svraw;

  HV *hv = (HV*)SvRV(sv);
  SV **svp = hv_fetch(hv, "ffi_pl_type", strlen("ffi_pl_type"), 0);

  return INT2PTR(ffi_pl_ffiperl_type *, SvIV((SV*)SvRV(*svp)));
}

XS(ffi_pl_ffiperl_sub_call)
{
  ffi_pl_ffiperl_function *self;
  int i,n, perl_arg_index, perl_type_index;
  SV *arg;
  ffi_pl_ffiperl_result result;
  ffi_pl_ffiperl_arguments arguments;
  SV *freeme = NULL; /* scratch space for custom perl handlers */
#ifndef FFI_PL_PROBE_RUNTIMESIZEDARRAYS
  void **argument_pointers;
  ffi_pl_ffiperl_argument *argument_slots;
#endif
  
  dVAR; dXSARGS;
  
  self = (ffi_pl_ffiperl_function*) CvXSUBANY(cv).any_ptr;

#define EXTRA_ARGS 0
#include "impl/libffi-perl/ffi_platypus_call.h"
}

/*
 * -1 until we have checked
 *  0 tried, not there
 *  1 tried, is there
 */
int have_math_longdouble = -1;  /* Math::LongDouble */
int have_math_complex    = -1;  /* Math::Complex    */

MODULE = FFI::Platypus::Impl::LibffiPerl PACKAGE = FFI::Platypus::Impl::LibffiPerl

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


INCLUDE: ../../../../../xs/Impl/LibffiPerl/Type.xs
INCLUDE: ../../../../../xs/Impl/LibffiPerl/Function.xs
INCLUDE: ../../../../../xs/Impl/LibffiPerl/ABI.xs
INCLUDE: ../../../../../xs/Impl/LibffiPerl/Record.xs
