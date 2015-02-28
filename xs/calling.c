#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"

#undef HAVE_ALLOCA
#include "ffi_platypus.h"
#include "ffi_platypus_guts.h"


int
ffi_pl_arguments_set_ffi(ffi_pl_arguments *arguments, int i, SV *arg_type, SV *arg, void **argument_pointers)
{
  ffi_type *ffi = INT2PTR(ffi_type *, SvIV((SV *) SvRV(arg_type)));

  switch(ffi->type)
  {
  case FFI_TYPE_UINT8:
    ffi_pl_arguments_set_uint8(arguments, i, SvOK(arg) ? SvUV(arg) : 0);
    break;
  case FFI_TYPE_SINT8:
    ffi_pl_arguments_set_sint8(arguments, i, SvOK(arg) ? SvIV(arg) : 0);
    break;
  case FFI_TYPE_UINT16:
    ffi_pl_arguments_set_uint16(arguments, i, SvOK(arg) ? SvUV(arg) : 0);
    break;
  case FFI_TYPE_SINT16:
    ffi_pl_arguments_set_sint16(arguments, i, SvOK(arg) ? SvIV(arg) : 0);
    break;
  case FFI_TYPE_UINT32:
    ffi_pl_arguments_set_uint32(arguments, i, SvOK(arg) ? SvUV(arg) : 0);
    break;
  case FFI_TYPE_SINT32:
    ffi_pl_arguments_set_sint32(arguments, i, SvOK(arg) ? SvIV(arg) : 0);
    break;
#ifdef HAVE_IV_IS_64
  case FFI_TYPE_UINT64:
    ffi_pl_arguments_set_uint64(arguments, i, SvOK(arg) ? SvUV(arg) : 0);
    break;
  case FFI_TYPE_SINT64:
    ffi_pl_arguments_set_sint64(arguments, i, SvOK(arg) ? SvIV(arg) : 0);
    break;
#else
  case FFI_TYPE_UINT64:
    ffi_pl_arguments_set_uint64(arguments, i, SvOK(arg) ? SvU64(arg) : 0);
    break;
  case FFI_TYPE_SINT64:
    ffi_pl_arguments_set_sint64(arguments, i, SvOK(arg) ? SvI64(arg) : 0);
    break;
#endif
  case FFI_TYPE_FLOAT:
    ffi_pl_arguments_set_float(arguments, i, SvOK(arg) ? SvNV(arg) : 0.0);
    break;
  case FFI_TYPE_DOUBLE:
    ffi_pl_arguments_set_double(arguments, i, SvOK(arg) ? SvNV(arg) : 0.0);
    break;
  case FFI_TYPE_POINTER:
    ffi_pl_arguments_set_pointer(arguments, i, SvOK(arg) ? INT2PTR(void*, SvIV(arg)) : NULL);
    break;
  default:
    warn("argument type not supported (%d)", i);
    break;
  }

  return 1;
}

int
ffi_pl_arguments_set_array(ffi_pl_arguments *arguments, int i, SV *type_sv, SV *arg, void **argument_pointers)
{
  void *ptr;
  ffi_pl_type *type = SV2ffi_pl_type(type_sv);
  int count = type->extra[0].array.element_count;
  int n;

  if(SvROK(arg) && SvTYPE(SvRV(arg)) == SVt_PVAV)
  {
    AV *av = (AV*) SvRV(arg);
    if(count == 0)
      count = av_len(av)+1;
    switch(type->ffi_type->type)
    {
    case FFI_TYPE_UINT8:
      Newx(ptr, count, uint8_t);
      for(n=0; n<count; n++)
      {
	((uint8_t*)ptr)[n] = SvUV(*av_fetch(av, n, 1));
      }
      break;
    case FFI_TYPE_SINT8:
      Newx(ptr, count, int8_t);
      for(n=0; n<count; n++)
      {
	((int8_t*)ptr)[n] = SvIV(*av_fetch(av, n, 1));
      }
      break;
    case FFI_TYPE_UINT16:
      Newx(ptr, count, uint16_t);
      for(n=0; n<count; n++)
      {
	((uint16_t*)ptr)[n] = SvUV(*av_fetch(av, n, 1));
      }
      break;
    case FFI_TYPE_SINT16:
      Newx(ptr, count, int16_t);
      for(n=0; n<count; n++)
      {
	((int16_t*)ptr)[n] = SvIV(*av_fetch(av, n, 1));
      }
      break;
    case FFI_TYPE_UINT32:
      Newx(ptr, count, uint32_t);
      for(n=0; n<count; n++)
      {
	((uint32_t*)ptr)[n] = SvUV(*av_fetch(av, n, 1));
      }
      break;
    case FFI_TYPE_SINT32:
      Newx(ptr, count, int32_t);
      for(n=0; n<count; n++)
      {
	((int32_t*)ptr)[n] = SvIV(*av_fetch(av, n, 1));
      }
      break;
    case FFI_TYPE_UINT64:
      Newx(ptr, count, uint64_t);
      for(n=0; n<count; n++)
      {
#ifdef HAVE_IV_IS_64
	((uint64_t*)ptr)[n] = SvUV(*av_fetch(av, n, 1));
#else
	((uint64_t*)ptr)[n] = SvU64(*av_fetch(av, n, 1));
#endif
      }
      break;
    case FFI_TYPE_SINT64:
      Newx(ptr, count, int64_t);
      for(n=0; n<count; n++)
      {
#ifdef HAVE_IV_IS_64
	((int64_t*)ptr)[n] = SvIV(*av_fetch(av, n, 1));
#else
	((int64_t*)ptr)[n] = SvI64(*av_fetch(av, n, 1));
#endif
      }
      break;
    case FFI_TYPE_FLOAT:
      Newx(ptr, count, float);
      for(n=0; n<count; n++)
      {
	((float*)ptr)[n] = SvNV(*av_fetch(av, n, 1));
      }
      break;
    case FFI_TYPE_DOUBLE:
      Newx(ptr, count, double);
      for(n=0; n<count; n++)
      {
	((double*)ptr)[n] = SvNV(*av_fetch(av, n, 1));
      }
      break;
    case FFI_TYPE_POINTER:
      Newx(ptr, count, void*);
      for(n=0; n<count; n++)
      {
	SV *sv = *av_fetch(av, n, 1);
	((void**)ptr)[n] = SvOK(sv) ? INT2PTR(void*, SvIV(sv)) : NULL;
      }
      break;
#ifdef FFI_PL_PROBE_LONGDOUBLE
    case FFI_TYPE_LONGDOUBLE:
      Newx(ptr, count, long double);
      for(n=0; n<count; n++)
      {
	SV *sv = *av_fetch(av, n, 1);
	ffi_pl_perl_to_long_double(sv, &((long double*)ptr)[n]);
      }
      break;
#endif
    default:
      Newxz(ptr, count*type->ffi_type->size, char);
      warn("argument type not supported (%d)", i);
      break;
    }
  }
  else
  {
    warn("passing non array reference into ffi/platypus array argument type");
    Newxz(ptr, count*type->ffi_type->size, char);
  }
  ffi_pl_arguments_set_pointer(arguments, i, ptr);

  return 1;
}

int
ffi_pl_arguments_set_customperl(ffi_pl_arguments *arguments, int i, SV *type_sv, SV *arg, void **argument_pointers)
{
  HV *hv = (HV*)SvRV(type_sv);
  SV **svp;
  SV *arg2 = NULL;
  SV *perl_to_native_sv = NULL;
  int n;
  int orig_i = i;

  svp = hv_fetch(hv, "perl_to_native", strlen("perl_to_native"), 0);
  if (svp) {
    perl_to_native_sv = *svp;
  }

  arg2 = ffi_pl_custom_array_perl(
    perl_to_native_sv,
    arg,
    i
  );

  if(arg2 != NULL && SvROK(arg2) && SvTYPE(SvRV(arg2)) == SVt_PVAV) {
    int j, perl_j;
    AV *type_av;
    svp = hv_fetch(hv, "underlying_types", strlen("underlying_types"), 0);
    type_av = (AV *)SvRV(*svp);

    for(j=0,perl_j=0; j<av_len((AV*)SvRV(arg2))+1; j++,perl_j++) {
      STRLEN len;
      const char *name;
      ffi_type *ffi;
      SV *arg3;
      SV *type2_sv;
      svp = av_fetch(type_av, j, 0);
      type2_sv = *svp;
      if(sv_derived_from(type2_sv, "FFI::Platypus::Type::CustomPerl")) {
	AV *av = newAV();
	HV *hv = (HV*)SvRV(type2_sv);
	int in_argument_count = 1;
	svp = hv_fetch(hv, "in_argument_count", strlen("in_argument_count"), 0);
	if (svp && SvIV(*svp) != 1) {
	  in_argument_count = SvIV(*svp);
	}
	for(n=0; n<in_argument_count; n++) {
	  svp = av_fetch((AV*)SvRV(arg2), perl_j, 0);
	  av_push(av, *svp);
	  perl_j++;
	}
	perl_j--;
	i += ffi_pl_arguments_set_customperl(arguments, i, type2_sv, (SV*)av, argument_pointers);
      } else {
	svp = av_fetch((AV*)SvRV(arg2), perl_j, 0);
	arg3 = *svp;
	i += ffi_pl_arguments_set_any(arguments, i, type2_sv, arg3, argument_pointers);
      }
    }

    svp = hv_fetch(hv, "argument_count", strlen("argument_count"), 0);
    if (svp) {
      i += SvIV(*svp) + 1 - j;
    } else {
      i += 1 - j;
    }

    return i - orig_i;
  } else {
    AV *av;
    STRLEN len;
    const char *name;
    ffi_type *ffi;
    svp = hv_fetch(hv, "underlying_types", strlen("underlying_types"), 0);
    av = (AV *)SvRV(*svp);
    svp = av_fetch(av, 0, 0);
    if(sv_derived_from(*svp, "FFI::Platypus::Type::String")) {
      if(arg2 != NULL) {
	ffi_pl_arguments_set_pointer(arguments, i, SvPV_nolen(arg2));
      }
    }
    else if(sv_derived_from(*svp, "FFI::Platypus::Type::FFI"))
    {
      if(arg2 != NULL)
      {
	ffi_pl_arguments_set_ffi(arguments, i, *svp, arg2, argument_pointers);
	SvREFCNT_dec(arg2);
      }
    }
    else if(sv_derived_from(*svp, "FFI::Platypus::Type::Array"))
    {
      ffi_pl_arguments_set_array(arguments, i, *svp, arg2, argument_pointers);
    }
    else if(sv_derived_from(*svp, "FFI::Platypus::Type::CustomPerl"))
    {
      int j,jmax;
      /* XXX fix me here */
      jmax = ffi_pl_arguments_set_customperl(arguments, i, *svp, arg, argument_pointers);
    }
    else
    {
      ffi = SV2ffi_pl_type(*svp)->ffi_type;
    }
  }

  svp = hv_fetch(hv, "argument_count", strlen("argument_count"), 0);
  if (svp) {
    return SvIV(*svp) + 1;
  }

  return 1;
}

int
ffi_pl_arguments_set_constant(ffi_pl_arguments *arguments, int i, SV *type_sv, SV *arg, void **argument_pointers)
{
  HV *hv = (HV*)SvRV(type_sv);
  SV **svp;
  SV *arg2 = NULL;
  SV *value = NULL;
  int n;
  int orig_i = i;

  svp = hv_fetch(hv, "value", strlen("value"), 0);
  if (svp) {
    value = *svp;
  }

  int j=0;
  AV *type_av;
  svp = hv_fetch(hv, "underlying_types", strlen("underlying_types"), 0);
  type_av = (AV *)SvRV(*svp);
  svp = av_fetch(type_av, j, 0);
  i += ffi_pl_arguments_set_any(arguments, i, *svp, value, argument_pointers);

  return i - orig_i;
}

/* I think it's safe to move this to the Type->new code, since we
 * currently do not have placeholder types for future types. */
int ffi_pl_customperl_count_native_arguments(SV *arg)
{
  HV *hv = (HV*)SvRV(arg);
  SV **svp;
  int extra_arguments = 0;
  int n=1;
  int i;

  svp = hv_fetch(hv, "native_argument_count", strlen("native_argument_count"), 0);
  if (svp) {
    return SvIV(*svp);
  }

  svp = hv_fetch(hv, "argument_count", strlen("argument_count"), 0);
  if (svp) {
    extra_arguments += SvIV(*svp);
    n = SvIV(*svp) + 1;
  }

  for(i=0; i<n; i++) {
    AV *av;
    SV **svp;
    STRLEN len;
    const char *name;
    ffi_type *ffi;

    svp = hv_fetch((HV*)SvRV(arg), "underlying_types", strlen("underlying_types"), 0);
    av = (AV *)SvRV(*svp);
    svp = av_fetch(av, i, 0);
    if(sv_derived_from(*svp, "FFI::Platypus::Type::CustomPerl")) {
      extra_arguments += ffi_pl_customperl_count_native_arguments(*svp)-1;
    }
  }

  hv_store(hv, "native_argument_count", strlen("native_argument_count"), newSViv(extra_arguments+1), 0);

  return extra_arguments+1;
}

int ffi_pl_prepare_customperl(ffi_pl_getter *getters, int i, ffi_type **ffi_argument_types, int n, SV *arg_type)
{
  HV *hv = (HV*)SvRV(arg_type);
  SV **svp;
  int d=0;
  int j;
  int perl_j;
  ffi_pl_type *tmp = SV2ffi_pl_type(arg_type);

  svp = hv_fetch(hv, "argument_count", strlen("argument_count"), 0);
  if (svp) {
    d = SvIV(*svp);
  }

  for(j=0,perl_j=0; j-1 < d; j++, perl_j++)
  {
    SV *ret_in=NULL, *ret_out;
    AV *av;
    SV **svp;
    STRLEN len;
    const char *name;
    ffi_type *ffi;

    svp = hv_fetch(tmp->hv, "underlying_types", strlen("underlying_types"), 0);
    av = (AV *)SvRV(*svp);
    svp = av_fetch(av, perl_j, 0);
    if(sv_derived_from(*svp, "FFI::Platypus::Type::FFI"))
    {
      ffi = INT2PTR(ffi_type *, SvIV((SV*)SvRV(*svp)));

      ffi_argument_types[n+j] = ffi;
    }
    else if(sv_derived_from(*svp, "FFI::Platypus::Type::Array"))
    {
      ffi = &ffi_type_pointer;

      ffi_argument_types[n+j] = ffi;
    }
    else if(sv_derived_from(*svp, "FFI::Platypus::Type::CustomPerl"))
    {
      int d2 = ffi_pl_prepare_customperl(getters, i+perl_j, ffi_argument_types, n+j, *svp);

      d += d2-1;
      j += d2-1;
    }
    else
    {
      ffi = SV2ffi_pl_type(*svp)->ffi_type;

      ffi_argument_types[n+j] = ffi;
    }
  }

  return d+1;
}

int
ffi_pl_arguments_set_record(ffi_pl_arguments *arguments, int i, SV *type_sv, SV *arg, void **argument_pointers)
{
  ffi_pl_type *type = SV2ffi_pl_type(type_sv);
  void *ptr;
  STRLEN size;
  int expected;
  expected = type->extra[0].record.size;
  if(SvROK(arg))
  {
    SV *arg2 = SvRV(arg);
    ptr = SvOK(arg2) ? SvPV(arg2, size) : NULL;
  }
  else
  {
    ptr = SvOK(arg) ? SvPV(arg, size) : NULL;
  }
  if(ptr != NULL && expected != 0 && size != expected)
    warn("record argument %d has wrong size (is %d, expected %d)", i, (int)size, expected);
  ffi_pl_arguments_set_pointer(arguments, i, ptr);

  return 1;
}

int
ffi_pl_arguments_set_perl_string(ffi_pl_arguments *arguments, int i, SV *type_sv, SV *arg, void **argument_pointers)
{
  ffi_pl_type *type = SV2ffi_pl_type(type_sv);

  switch(type->extra[0].string.platypus_string_type)
  {
  case FFI_PL_STRING_RW:
  case FFI_PL_STRING_RO:
    ffi_pl_arguments_set_string(arguments, i, SvOK(arg) ? SvPV_nolen(arg) : NULL);
    break;
  case FFI_PL_STRING_FIXED:
    {
      int expected;
      STRLEN size;
      void *ptr;
      expected = type->extra[0].string.size;
      ptr = SvOK(arg) ? SvPV(arg, size) : NULL;
      if(ptr != NULL && expected != 0 && size != expected)
	warn("fixed string argument %d has wrong size (is %d, expected %d)", i, (int)size, expected);
      ffi_pl_arguments_set_pointer(arguments, i, ptr);
    }
    break;
  }

  return 1;
}

int
ffi_pl_arguments_set_ref(ffi_pl_arguments *arguments, int i, SV *type_sv, SV *arg, void **argument_pointers)
{
  ffi_pl_type *type = SV2ffi_pl_type(type_sv);
  void *ptr;

  if(SvROK(arg)) /* TODO: and a scalar ref */
  {
    SV *arg2 = SvRV(arg);
    if(SvTYPE(arg2) < SVt_PVAV)
    {
      switch(type->ffi_type->type)
      {
      case FFI_TYPE_UINT8:
	Newx_or_alloca(ptr, 1, uint8_t);
	*((uint8_t*)ptr) = SvOK(arg2) ? SvUV(arg2) : 0;
	break;
      case FFI_TYPE_SINT8:
	Newx_or_alloca(ptr, 1, int8_t);
	*((int8_t*)ptr) = SvOK(arg2) ? SvIV(arg2) : 0;
	break;
      case FFI_TYPE_UINT16:
	Newx_or_alloca(ptr, 1, uint16_t);
	*((uint16_t*)ptr) = SvOK(arg2) ? SvUV(arg2) : 0;
	break;
      case FFI_TYPE_SINT16:
	Newx_or_alloca(ptr, 1, int16_t);
	*((int16_t*)ptr) = SvOK(arg2) ? SvIV(arg2) : 0;
	break;
      case FFI_TYPE_UINT32:
	Newx_or_alloca(ptr, 1, uint32_t);
	*((uint32_t*)ptr) = SvOK(arg2) ? SvUV(arg2) : 0;
	break;
      case FFI_TYPE_SINT32:
	Newx_or_alloca(ptr, 1, int32_t);
	*((int32_t*)ptr) = SvOK(arg2) ? SvIV(arg2) : 0;
	break;
      case FFI_TYPE_UINT64:
	Newx_or_alloca(ptr, 1, uint64_t);
#ifdef HAVE_IV_IS_64
	*((uint64_t*)ptr) = SvOK(arg2) ? SvUV(arg2) : 0;
#else
	*((uint64_t*)ptr) = SvOK(arg2) ? SvU64(arg2) : 0;
#endif
	break;
      case FFI_TYPE_SINT64:
	Newx_or_alloca(ptr, 1, int64_t);
#ifdef HAVE_IV_IS_64
	*((int64_t*)ptr) = SvOK(arg2) ? SvIV(arg2) : 0;
#else
	*((int64_t*)ptr) = SvOK(arg2) ? SvI64(arg2) : 0;
#endif
	break;
      case FFI_TYPE_FLOAT:
	Newx_or_alloca(ptr, 1, float);
	*((float*)ptr) = SvOK(arg2) ? SvNV(arg2) : 0.0;
	break;
      case FFI_TYPE_DOUBLE:
	Newx_or_alloca(ptr, 1, double);
	*((double*)ptr) = SvOK(arg2) ? SvNV(arg2) : 0.0;
	break;
      case FFI_TYPE_POINTER:
	Newx_or_alloca(ptr, 1, void*);
	{
	  SV *tmp = SvRV(arg);
	  *((void**)ptr) = SvOK(tmp) ? INT2PTR(void *, SvIV(tmp)) : NULL;
	}
	break;
#ifdef FFI_PL_PROBE_LONGDOUBLE
      case FFI_TYPE_LONGDOUBLE:
	Newx_or_alloca(ptr, 1, long double);
	ffi_pl_perl_to_long_double(arg2, (long double*)ptr);
	break;
#endif
      default:
	warn("argument type not supported (%d)", i);
	*((void**)ptr) = NULL;
	break;
      }
    }
    else
    {
      warn("argument type not a reference to scalar (%d)", i);
      ptr = NULL;
    }
  }
  else
  {
    ptr = NULL;
  }
  ffi_pl_arguments_set_pointer(arguments, i, ptr);

  return 1;
}

int
ffi_pl_arguments_set_closure(ffi_pl_arguments *arguments, int i, SV *type_sv, SV *arg, void **argument_pointers)
{
  ffi_pl_type *type = SV2ffi_pl_type(type_sv);

  if(!SvROK(arg))
  {
    ffi_pl_arguments_set_pointer(arguments, i, SvOK(arg) ? INT2PTR(void*, SvIV(arg)) : NULL);

    return 1;
  }
  else
  {
    ffi_pl_closure *closure;
    ffi_status ffi_status;

    SvREFCNT_inc(arg);

    closure = ffi_pl_closure_get_data(arg, type_sv);
    if(closure != NULL)
    {
      ffi_pl_arguments_set_pointer(arguments, i, closure->function_pointer);
    }
    else
    {
      Newx(closure, 1, ffi_pl_closure);
      closure->ffi_closure = ffi_closure_alloc(sizeof(ffi_closure), &closure->function_pointer);
      if(closure->ffi_closure == NULL)
      {
	Safefree(closure);
	ffi_pl_arguments_set_pointer(arguments, i, NULL);
	warn("unable to allocate memory for closure");
      }
      else
      {
	closure->type = type_sv;

	ffi_status = ffi_prep_closure_loc(
	  closure->ffi_closure,
	  &type->extra[0].closure.ffi_cif,
	  ffi_pl_closure_call,
	  closure,
	  closure->function_pointer
	);

	if(ffi_status != FFI_OK)
	{
	  ffi_closure_free(closure->ffi_closure);
	  Safefree(closure);
	  ffi_pl_arguments_set_pointer(arguments, i, NULL);
	  warn("unable to create closure");
	}
	else
	{
	  SV **svp;
	  SV **hvp;
	  SV *keysv;
	  const char *key;
	  STRLEN len;

	  closure->coderef = arg;
	  keysv = ffi_pl_closure_add_data(arg, closure);
	  key = SvPV(keysv, len);
	  hvp = hv_fetch((HV *)SvRV((SV *)closure->coderef), "cbdata", 6, 0);
	  if (!hvp)
	    croak("couldn't create closure type hash");
	  svp = hv_fetch((HV *)SvRV(*hvp), key, len, 0);
	  if (!svp)
	    croak("couldn't create closure type hash (2)");
	  svp = hv_fetch((HV *)SvRV(*svp), "type", 4, 0);
	  if (!svp)
	    croak("couldn't create closure type hash (3)");
	  /* No SvREFCNT_inc here! The hash entry will stay
	     alive as long as the closure exists, and we want to
	     avoid having a custom DESTROY routine for
	     closures. */
	  closure->type = *svp;
	  ffi_pl_arguments_set_pointer(arguments, i, closure->function_pointer);
	  SvREFCNT_dec(keysv);
	}
      }
    }
  }

  return 1;
}

int
ffi_pl_arguments_set_exoticfloat(ffi_pl_arguments *arguments, int i, SV *type_sv, SV *arg, void **argument_pointers)
{
  ffi_pl_type *type = SV2ffi_pl_type(type_sv);

  switch(type->ffi_type->type)
  {
#ifdef FFI_PL_PROBE_LONGDOUBLE
  case FFI_TYPE_LONGDOUBLE:
  {
    long double *ptr;
    Newx_or_alloca(ptr, 1, long double);
    argument_pointers[i] = ptr;
    ffi_pl_perl_to_long_double(arg, ptr);
  }
  break;
#endif
#ifdef FFI_PL_PROBE_COMPLEX
  case FFI_TYPE_COMPLEX:
    switch(type->ffi_type->size)
    {
    case  8:
    {
      float *ptr;
      Newx_or_alloca(ptr, 2, float complex);
      argument_pointers[i] = ptr;
      ffi_pl_perl_complex_float(arg, ptr);
    }
    break;
    case 16:
    {
      double *ptr;
      Newx_or_alloca(ptr, 2, double);
      argument_pointers[i] = ptr;
      ffi_pl_perl_complex_double(arg, ptr);
    }
    break;
    default :
      warn("argument type not supported (%d)", i);
      break;
    }
    break;
#endif
  default:
    warn("argument type not supported (%d)", i);
    break;
  }

  return 1;
}

int
ffi_pl_arguments_set_any(ffi_pl_arguments *arguments, int i, SV *type_sv, SV *arg, void **argument_pointers)
{
  if (sv_derived_from(type_sv, "FFI::Platypus::Type::FFI"))
  {
    return ffi_pl_arguments_set_ffi(arguments, i, type_sv, arg, argument_pointers);
  } else {
    if(sv_derived_from(type_sv, "FFI::Platypus::Type::String"))
    {
      return ffi_pl_arguments_set_perl_string(arguments, i, type_sv, arg, argument_pointers);
    }
    else if(sv_derived_from(type_sv, "FFI::Platypus::Type::Pointer"))
    {
      return ffi_pl_arguments_set_ref(arguments, i, type_sv, arg, argument_pointers);
    }
    else if(sv_derived_from(type_sv, "FFI::Platypus::Type::Record"))
    {
      return ffi_pl_arguments_set_record(arguments, i, type_sv, arg, argument_pointers);
    }
    else if(sv_derived_from(type_sv, "FFI::Platypus::Type::Array"))
    {
      return ffi_pl_arguments_set_array(arguments, i, type_sv, arg, argument_pointers);
    }
    else if(sv_derived_from(type_sv, "FFI::Platypus::Type::Closure"))
    {
      return ffi_pl_arguments_set_closure(arguments, i, type_sv, arg, argument_pointers);
    }
    else if(sv_derived_from(type_sv, "FFI::Platypus::Type::CustomPerl"))
    {
      return ffi_pl_arguments_set_customperl(arguments, i, type_sv, arg, argument_pointers);
    }
    else if(sv_derived_from(type_sv, "FFI::Platypus::Type::ExoticFloat"))
    {
      return ffi_pl_arguments_set_exoticfloat(arguments, i, type_sv, arg, argument_pointers);
    }
  }
}

int
ffi_pl_arguments_set_ref_post(ffi_pl_arguments *arguments, int i, SV *type_sv, SV *arg, void **argument_pointers)
{
  ffi_pl_type *type = SV2ffi_pl_type(type_sv);
  void *ptr = ffi_pl_arguments_get_pointer(arguments, i-1);
  if(ptr != NULL)
  {
    if(!SvREADONLY(SvRV(arg)))
    {
      switch(type->ffi_type->type)
      {
      case FFI_TYPE_UINT8:
	sv_setuv(SvRV(arg), *((uint8_t*)ptr));
	break;
      case FFI_TYPE_SINT8:
	sv_setiv(SvRV(arg), *((int8_t*)ptr));
	break;
      case FFI_TYPE_UINT16:
	sv_setuv(SvRV(arg), *((uint16_t*)ptr));
	break;
      case FFI_TYPE_SINT16:
	sv_setiv(SvRV(arg), *((int16_t*)ptr));
	break;
      case FFI_TYPE_UINT32:
	sv_setuv(SvRV(arg), *((uint32_t*)ptr));
	break;
      case FFI_TYPE_SINT32:
	sv_setiv(SvRV(arg), *((int32_t*)ptr));
	break;
      case FFI_TYPE_UINT64:
#ifdef HAVE_IV_IS_64
	sv_setuv(SvRV(arg), *((uint64_t*)ptr));
#else
	sv_setu64(SvRV(arg), *((uint64_t*)ptr));
#endif
	break;
      case FFI_TYPE_SINT64:
#ifdef HAVE_IV_IS_64
	sv_setiv(SvRV(arg), *((int64_t*)ptr));
#else
	sv_seti64(SvRV(arg), *((int64_t*)ptr));
#endif
	break;
      case FFI_TYPE_FLOAT:
	sv_setnv(SvRV(arg), *((float*)ptr));
	break;
      case FFI_TYPE_POINTER:
	if( *((void**)ptr) == NULL)
	  sv_setsv(SvRV(arg), &PL_sv_undef);
	else
	  sv_setiv(SvRV(arg), PTR2IV(*((void**)ptr)));
	break;
      case FFI_TYPE_DOUBLE:
	sv_setnv(SvRV(arg), *((double*)ptr));
	break;
#ifdef FFI_PL_PROBE_LONGDOUBLE
      case FFI_TYPE_LONGDOUBLE:
      {
	SV *arg2 = SvRV(arg);
	ffi_pl_long_double_to_perl(arg2,(long double*)ptr);
      }
      break;
#endif
      }
    }
  }
#ifndef HAVE_ALLOCA
  Safefree(ptr);
#endif

  return 1;
}

int
ffi_pl_arguments_set_array_post(ffi_pl_arguments *arguments, int i, SV *type_sv, SV *arg, void **argument_pointers)
{
  ffi_pl_type *type = SV2ffi_pl_type(type_sv);
  void *ptr = ffi_pl_arguments_get_pointer(arguments, i-1);
  int count = type->extra[0].array.element_count;
  int n;

  if(SvROK(arg) && SvTYPE(SvRV(arg)) == SVt_PVAV)
  {
    AV *av = (AV*) SvRV(arg);
    if(count == 0)
      count = av_len(av)+1;
    switch(type->ffi_type->type)
    {
    case FFI_TYPE_UINT8:
      for(n=0; n<count; n++)
      {
	sv_setuv(*av_fetch(av, n, 1), ((uint8_t*)ptr)[n]);
      }
      break;
    case FFI_TYPE_SINT8:
      for(n=0; n<count; n++)
      {
	sv_setiv(*av_fetch(av, n, 1), ((int8_t*)ptr)[n]);
      }
      break;
    case FFI_TYPE_UINT16:
      for(n=0; n<count; n++)
      {
	sv_setuv(*av_fetch(av, n, 1), ((uint16_t*)ptr)[n]);
      }
      break;
    case FFI_TYPE_SINT16:
      for(n=0; n<count; n++)
      {
	sv_setiv(*av_fetch(av, n, 1), ((int16_t*)ptr)[n]);
      }
      break;
    case FFI_TYPE_UINT32:
      for(n=0; n<count; n++)
      {
	sv_setuv(*av_fetch(av, n, 1), ((uint32_t*)ptr)[n]);
      }
      break;
    case FFI_TYPE_SINT32:
      for(n=0; n<count; n++)
      {
	sv_setiv(*av_fetch(av, n, 1), ((int32_t*)ptr)[n]);
      }
      break;
    case FFI_TYPE_UINT64:
      for(n=0; n<count; n++)
      {
#ifdef HAVE_IV_IS_64
	sv_setuv(*av_fetch(av, n, 1), ((uint64_t*)ptr)[n]);
#else
	sv_setu64(*av_fetch(av, n, 1), ((uint64_t*)ptr)[n]);
#endif
      }
      break;
    case FFI_TYPE_SINT64:
      for(n=0; n<count; n++)
      {
#ifdef HAVE_IV_IS_64
	sv_setiv(*av_fetch(av, n, 1), ((int64_t*)ptr)[n]);
#else
	sv_seti64(*av_fetch(av, n, 1), ((int64_t*)ptr)[n]);
#endif
      }
      break;
    case FFI_TYPE_FLOAT:
      for(n=0; n<count; n++)
      {
	sv_setnv(*av_fetch(av, n, 1), ((float*)ptr)[n]);
      }
      break;
    case FFI_TYPE_POINTER:
      for(n=0; n<count; n++)
      {
	if( ((void**)ptr)[n] == NULL)
	{
	  av_store(av, n, &PL_sv_undef);
	}
	else
	{
	  sv_setnv(*av_fetch(av,n,1), PTR2IV( ((void**)ptr)[n]) );
	}
      }
      break;
    case FFI_TYPE_DOUBLE:
      for(n=0; n<count; n++)
      {
	sv_setnv(*av_fetch(av, n, 1), ((double*)ptr)[n]);
      }
      break;
#ifdef FFI_PL_PROBE_LONGDOUBLE
    case FFI_TYPE_LONGDOUBLE:
      for(n=0; n<count; n++)
      {
	SV *sv;
	sv = *av_fetch(av, n, 1);
	ffi_pl_long_double_to_perl(sv, &((long double*)ptr)[n]);
      }
      break;
#endif
    }
  }
#ifndef HAVE_ALLOCA
  Safefree(ptr);
#endif

  return 1;
}

int
ffi_pl_arguments_set_closure_post(ffi_pl_arguments *arguments, int i, SV *type_sv, SV *arg, void **argument_pointers)
{
  if(SvROK(arg))
  {
    SvREFCNT_dec(arg);
  }

  return 1;
}

int
ffi_pl_arguments_set_custom_perl_post(ffi_pl_arguments *arguments, int i, SV *type_sv, SV *arg, void **argument_pointers)
{
  ffi_pl_type *type = SV2ffi_pl_type(type_sv);
  HV *hv = (HV*)SvRV(type_sv);
  SV **svp;
  SV *arg2 = NULL;
  int native_count = ffi_pl_customperl_count_native_arguments(type_sv);
  int n;

  i -= native_count;

  svp = hv_fetch(hv, "perl_to_native_post", strlen("perl_to_native_post"), 0);
  if (svp) {
    SV *perl_to_native_post_sv = *svp;

    ffi_pl_custom_perl_cb(perl_to_native_post_sv, arg, i);
  }

  return native_count;
}

int
ffi_pl_arguments_set_exoticfloat_post(ffi_pl_arguments *arguments, int i, SV *type_sv, SV *arg, void **argument_pointers)
{
  void *ptr = argument_pointers[i-1];
  Safefree(ptr);

  return 1;
}

int
ffi_pl_arguments_set_any_post(ffi_pl_arguments *arguments, int i, SV *type_sv, SV *arg, void **argument_pointers)
{
  if (sv_derived_from(type_sv, "FFI::Platypus::Type::Pointer"))
  {
    return ffi_pl_arguments_set_ref_post(arguments, i, type_sv, arg, argument_pointers);
  }
  else if (sv_derived_from(type_sv, "FFI::Platypus::Type::Array"))
  {
    return ffi_pl_arguments_set_array_post(arguments, i, type_sv, arg, argument_pointers);
  }
  else if (sv_derived_from(type_sv, "FFI::Platypus::Type::CustomPerl"))
  {
    return ffi_pl_arguments_set_custom_perl_post(arguments, i, type_sv, arg, argument_pointers);
  }
  else if (sv_derived_from(type_sv, "FFI::Platypus::Type::Closure"))
  {
    return ffi_pl_arguments_set_closure_post(arguments, i, type_sv, arg, argument_pointers);
  }
  else if (sv_derived_from(type_sv, "FFI::Platypus::Type::ExoticFloat"))
  {
    return ffi_pl_arguments_set_exoticfloat_post(arguments, i, type_sv, arg, argument_pointers);
  }

  return 1;
}
/* Local Variables: */
/* c-basic-offset: 2 */
/* c-file-style: "linux" */
/* End: */