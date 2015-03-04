#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"

#include "ffi_platypus.h"

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

ffi_pl_type *SV2ffi_pl_type(void *svraw)
{
  SV *sv = svraw;

  if(sv_isobject(sv) && sv_derived_from(sv, "FFI::Platypus::Type")) {
    HV *hv = (HV*)SvRV(sv);
    SV **svp = hv_fetch(hv, "ffi_pl_type", strlen("ffi_pl_type"), 0);
    if (svp == NULL)
      Perl_croak(aTHX_ "ret is missing the ffi_pl_type hash entry");
    return INT2PTR(ffi_pl_type *, SvIV((SV*)SvRV(*svp)));
  } else
    Perl_croak(aTHX_ "ret is not of type FFI::Platypus::Type");
}

ffi_pl_type *SV2ffi_pl_type_nocheck(void *svraw)
{
  SV *sv = svraw;

  HV *hv = (HV*)SvRV(sv);
  SV **svp = hv_fetch(hv, "ffi_pl_type", strlen("ffi_pl_type"), 0);

  return INT2PTR(ffi_pl_type *, SvIV((SV*)SvRV(*svp)));
}

#include "impl/libffi-perl/ffi_platypus.h"
#include "impl/libffi-perl/ffi_platypus_guts.h"

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

