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

XS(ffi_pl_rtypes_sub_call)
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
