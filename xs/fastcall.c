#define PERL_NO_GET_CONTEXT /* see perlguts */
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
//#include "ppport.h"

#include "ffi_platypus.h"
#include "ffi_platypus_rtypes.h"
#include "ffi_platypus_rtypes_guts.h"

#ifndef HAVE_IV_IS_64
#include "perl_math_int64.h"
#endif

#include "ffi_platypus_guts.h"

/* this code is shared between implementations. */
XS(ffi_pl_method_call)
{
  ffi_pl_cached_method *cached;
  void (*body)(pTHX_ void *self, int extra_args);
  void *self;
  SV *object;
  SV *weakref;
  cached = (ffi_pl_cached_method *) CvXSUBANY(cv).any_ptr;

  dVAR; dXSARGS; dORIGMARK;
  object = ST(0);
  PUSHMARK(ORIGMARK);

#if 0
  if(items == 0)
  {
    croak("cannot call an object method without arguments");
  }
#endif

  weakref = cached->weakref;
  body = cached->body;
  self = cached->function;

  if(weakref
  && SvROK(object)
  && (SvRV(weakref) == SvRV(object))) {
    /* the common case: fall through to the calling code */
    body(aTHX_ self, NULL == (ST(0) = cached->argument));
  }
  else
  {
    SV *first_argument = NULL;

    /* the slow case. Go back to Perl to retrieve our method. */
    ffi_pl_make_method(cached, &self, &body, &first_argument, object);
    SPAGAIN;

    if(!self) {
      croak("could not generate a method on demand");
    }

    if(first_argument != NULL)
    {
      if(SvTYPE(first_argument) == SVt_PVAV) {
	AV *arguments = (AV *)first_argument;
	AV *results = newAV();
	int i;

	POPMARK; /* undo our optimistic orig mark push */
	ENTER;
	SAVETMPS;

	PUSHMARK(SP);
	for(i=0; i<av_len(arguments)+1; i++)
	{
	  SV **svp = av_fetch(arguments, i, 0);
	  XPUSHs(*svp);
	}

	for(i=1; i<items; i++)
	{
	  XPUSHs(ST(i));
	}
	PUTBACK;

	body(aTHX_ self, 0);
	SPAGAIN;

	{
	  dITEMS;
	  for(i=0; i<items; i++)
	  {
	    SV *sv = POPs;
	    av_push(results, SvREFCNT_inc(sv));
	  }
	}
	SPAGAIN;

	{
	  dXSARGS; /* this time, we don't push the mark back */
	}

	for(i=0; i<av_len(results)+1; i++)
	{
	  XPUSHs(*av_fetch(results, i, 0));
	}

	sv_2mortal((SV *)results);
	XSRETURN(av_len(results)+1);
      } else {
	ST(0) = first_argument;
      }

    }
    body(aTHX_ self, first_argument == NULL);
  }
}
