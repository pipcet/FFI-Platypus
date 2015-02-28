#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"

#include "ffi_platypus.h"
#include "ffi_platypus_guts.h"

SV*
ffi_pl_custom_perl(SV *subref, SV *in_arg, int i)
{
  if(subref == NULL)
  {
    return newSVsv(in_arg);
  }
  else
  {
    dSP;

    int count;
    SV *out_arg;

    ENTER;
    SAVETMPS;
    PUSHMARK(SP);
    XPUSHs(in_arg);
    XPUSHs(sv_2mortal(newSViv(i)));
    PUTBACK;

    count = call_sv(subref, G_ARRAY);

    SPAGAIN;

    if(count >= 1)
      out_arg = SvREFCNT_inc(POPs);
    else
      out_arg = NULL;

    PUTBACK;
    FREETMPS;
    LEAVE;

    return out_arg;
  }
}

SV*
ffi_pl_custom_array_perl(SV *subref, SV *in_arg, int i)
{
  if(subref == NULL)
  {
    return newSVsv(in_arg);
  }
  else
  {
    dSP;

    int count;
    SV *out_arg;
    AV *av;

    ENTER;
    SAVETMPS;
    PUSHMARK(SP);
    av = (AV*)SvRV(in_arg);

    for(i=0; i<av_len(av)+1; i++) {
      SV **svp;
      svp = av_fetch(av, i, 0);
      XPUSHs(*svp);
    }

    XPUSHs(sv_2mortal(newSViv(i)));
    PUTBACK;

    count = call_sv(subref, G_ARRAY);

    SPAGAIN;

    if(count == 0)
      out_arg = NULL;
    else {
      int i;

      out_arg = newRV_noinc((SV*)newAV());

      av_unshift((AV*)SvRV(out_arg), count);
      for(i=0; i<count; i++) {
	av_store((AV*)SvRV(out_arg), count-i-1, SvREFCNT_inc(POPs));
      }
    }

    PUTBACK;
    FREETMPS;
    LEAVE;

    return out_arg;
  }
}

void
ffi_pl_custom_perl_cb(SV *subref, SV *in_arg, int i)
{
  dSP;
  ENTER;
  SAVETMPS;
  PUSHMARK(SP);
  XPUSHs(in_arg);
  XPUSHs(sv_2mortal(newSViv(i)));
  PUTBACK;
  call_sv(subref, G_VOID|G_DISCARD);
  FREETMPS;
  LEAVE;
}
