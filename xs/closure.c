#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"

#include "ffi_platypus.h"
#include "ffi_platypus_guts.h"

#ifndef HAVE_IV_IS_64
#include "perl_math_int64.h"
#endif

SV *
ffi_pl_closure_add_data(SV *closure, SV *type, void *closure_pointer)
{
  dSP;
  SV *sv;
  SV *closure_data = newSV(0);

  sv_setref_pv(closure_data, "FFI::Platypus::ClosureData", closure_pointer);

  ENTER;
  SAVETMPS;
  PUSHMARK(SP);
  XPUSHs(closure);
  XPUSHs(sv_2mortal(closure_data));
  XPUSHs(type);
  PUTBACK;
  call_pv("FFI::Platypus::Closure::add_data", G_SCALAR);
  SPAGAIN;
  sv = SvREFCNT_inc(POPs);
  PUTBACK;
  FREETMPS;
  LEAVE;

  return sv;
}

void *
ffi_pl_closure_get_data(SV *closure, SV *type)
{
  dSP;
  int count;
  ffi_pl_closure *ret;

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
