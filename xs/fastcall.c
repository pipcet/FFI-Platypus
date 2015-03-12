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
#if 0
    else if(cached->weakref
	 && SvPOK(object)
	 && SvPOK(cached->weakref)
	 && sv_eq(cached->weakref, ST(0)))
    {
      /* slightly slower: class method. Also fall through. */
      first_argument = cached->argument;
    }
#endif
    if(1)
    {
      /* the slow case. Go back to Perl to retrieve our method. */
      ffi_pl_make_method(cached, &self, &body, &first_argument, object);
      SPAGAIN;

      if(!self) {
	croak("could not generate a method on demand");
      }
    }

    if(first_argument != NULL)
      ST(0) = first_argument;

    body(aTHX_ self, first_argument == NULL);
  }
}
