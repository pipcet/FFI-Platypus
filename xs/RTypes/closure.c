#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"

#include "ffi_platypus.h"
#include "ffi_platypus_rtypes.h"
#include "ffi_platypus_rtypes_guts.h"

#ifndef HAVE_IV_IS_64
#include "perl_math_int64.h"
#endif

SV *
ffi_pl_rtypes_closure_add_data(SV *closure, SV *type, void *closure_pointer)
{
  dSP;
  SV *sv;
  SV *closure_data = newSV(0);

  sv_setref_pv(closure_data, "FFI::Platypus::RTypes::ClosureData", closure_pointer);

  ENTER;
  SAVETMPS;
  PUSHMARK(SP);
  XPUSHs(closure);
  XPUSHs(sv_2mortal(closure_data));
  XPUSHs(type);
  PUTBACK;
  call_pv("FFI::Platypus::RTypes::Closure::add_data", G_SCALAR);
  SPAGAIN;
  sv = SvREFCNT_inc(POPs);
  PUTBACK;
  FREETMPS;
  LEAVE;

  return sv;
}

ffi_pl_rtypes_closure *
ffi_pl_rtypes_closure_get_data(SV *closure, SV *type)
{
  dSP;
  int count;
  ffi_pl_rtypes_closure *ret;

  ENTER;
  SAVETMPS;
  PUSHMARK(SP);
  XPUSHs(closure);
  XPUSHs(type);
  PUTBACK;
  count = call_pv("FFI::Platypus::Closure::get_data", G_SCALAR);
  SPAGAIN;

  if (count != 1)
    ret = NULL;
  else
    ret = INT2PTR(void*, POPi);

  PUTBACK;
  FREETMPS;
  LEAVE;

  return ret;
}

void
ffi_pl_rtypes_closure_call(ffi_cif *ffi_cif, void *result, void **arguments, void *user)
{
  dSP;

  ffi_pl_rtypes_closure *closure = (ffi_pl_rtypes_closure*) user;
  int flags;
  int i;
  int count;
  SV *sv;
  SV **svp;
  AV *av;
  HV *hv = (HV*)SvRV((SV*)closure->type);

  svp = hv_fetch(hv, "flags", strlen("flags"), 0);
  flags = SvIV(*svp);

  if(!(flags & G_NOARGS))
  {
    ENTER;
    SAVETMPS;
  }

  PUSHMARK(SP);

  if(!(flags & G_NOARGS))
  {
    svp = hv_fetch(hv, "argument_types", strlen("argument_types"), 0);
    av = (AV*)SvRV(*svp);
    for(i=0; i< ffi_cif->nargs; i++)
    {
      native_to_perl_method_t f;
      SV *arg_type_sv;
      SV *arg;
      SV *sv = sv_newmortal();

      svp = av_fetch(av, i, 0);
      arg_type_sv = *svp;

      PUTBACK;
      f = ffi_pl_rtypes_native_to_perl_method(arg_type_sv, ffi_pl_rtypes_extra_data(arg_type_sv));
      SPAGAIN;

      arg = f(sv, (ffi_pl_result *)arguments[i], arg_type_sv, ffi_pl_rtypes_extra_data(arg_type_sv));
      SPAGAIN;
      arg = newSVsv(arg);
      SvREFCNT_inc(arg);
      XPUSHs(arg);
      PUTBACK;
    }
  }

  svp = hv_fetch((HV *)closure->coderef, "code", 4, 0);
  if (svp)
    count = call_sv(*svp, flags | G_EVAL);
  else
    count = 0;

  SPAGAIN;
  if(SvTRUE(ERRSV))
  {
#ifdef warn_sv
    warn_sv(ERRSV);
#else
    warn("%s", SvPV_nolen(ERRSV));
#endif
  }

  if(!(flags & G_DISCARD))
  {
    ffi_pl_rtypes_arguments arguments;
    void *slot[1];
    SV *freeme = NULL;

    arguments.count = 1;
    arguments.pointers = (ffi_pl_argument **)(slot);
    slot[0] = result;

    if(count != 1)
      sv = &PL_sv_undef;
    else
      sv = POPs;

    svp = hv_fetch(hv, "return_type", strlen("return_type"), 0);
    SV *ret_sv = *svp;

    perl_to_native_method_t perl_to_native = ffi_pl_rtypes_perl_to_native_method(ret_sv, ffi_pl_rtypes_extra_data(ret_sv));
    SPAGAIN;
    int count2 = perl_to_native(&arguments, 0, ret_sv, ffi_pl_rtypes_extra_data(ret_sv), sv, &freeme);
    SPAGAIN;

    if (count2 > 1)
    {
      croak("memory corruption in closure return");
    }
    if (arguments.pointers[0] != result)
    {
      croak("cannot change size of closure return value");
    }
    if (freeme != NULL)
    {
      warn("leaking memory in closure return");
    }

    PUTBACK;
  }

  if(!(flags & G_NOARGS))
  {
    FREETMPS;
    LEAVE;
  }
}

