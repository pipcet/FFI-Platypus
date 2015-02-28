#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"

#undef HAVE_ALLOCA
#include "ffi_platypus.h"
#include "ffi_platypus_guts.h"


int
ffi_pl_arguments_set_ffi(ffi_pl_arguments *arguments, int i, SV *arg_type, SV *arg)
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
ffi_pl_arguments_set_array(ffi_pl_arguments *arguments, int i, SV *type_sv, SV *arg)
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
ffi_pl_arguments_set_customperl(ffi_pl_arguments *arguments, int i, SV *type_sv, SV *arg)
{
  HV *hv = (HV*)SvRV(type_sv);
  SV **svp;
  SV *arg2 = NULL;
  SV *perl_to_native_sv = NULL;
  int n;

  svp = hv_fetch(hv, "perl_to_native", strlen("perl_to_native"), 0);
  if (svp) {
    perl_to_native_sv = *svp;
  }

  arg2 = ffi_pl_custom_perl(
    perl_to_native_sv,
    arg,
    i
  );

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
      ffi_pl_arguments_set_ffi(arguments, i, *svp, arg2);
      SvREFCNT_dec(arg2);
    }
  }
  else if(sv_derived_from(*svp, "FFI::Platypus::Type::Array"))
  {
    int count = SV2ffi_pl_type(*svp)->extra[0].array.element_count;
    ffi = SV2ffi_pl_type(*svp)->ffi_type;

    void *ptr;
    if(SvROK(arg2) && SvTYPE(SvRV(arg2)) == SVt_PVAV)
    {
      AV *av = (AV*) SvRV(arg2);
      if(count == 0)
	count = av_len(av)+1;
      switch(ffi->type)
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
	Newxz(ptr, count*ffi->size, char);
	warn("argument type not supported (%d)", i);
	break;
      }
    }
    else
    {
      warn("passing non array reference into ffi/platypus array argument type");
      Newxz(ptr, count*ffi->size, char);
    }
    ffi_pl_arguments_set_pointer(arguments, i, ptr);
  }
  else if(sv_derived_from(*svp, "FFI::Platypus::Type::CustomPerl"))
  {
    int j,jmax;

    jmax = ffi_pl_arguments_set_customperl(arguments, i, *svp, arg);
  }
  else
  {
    ffi = SV2ffi_pl_type(*svp)->ffi_type;
  }

  svp = hv_fetch(hv, "argument_count", strlen("argument_count"), 0);
  if (svp) {
    return SvIV(*svp) + 1;
  }

  return 1;
}

int ffi_pl_prepare_customperl(SV **argument_types, ffi_type **ffi_argument_types, int n, SV *arg_type)
{
  HV *hv = (HV*)SvRV(arg_type);
  SV **svp;
  int d=0;
  int j;
  ffi_pl_type *tmp = SV2ffi_pl_type(arg_type);

  svp = hv_fetch(hv, "argument_count", strlen("argument_count"), 0);
  if (svp) {
    d = SvIV(*svp);
  }

  for(j=0; j-1 < d; j++)
  {
    SV *ret_in=NULL, *ret_out;
    AV *av;
    SV **svp;
    STRLEN len;
    const char *name;
    ffi_type *ffi;

    svp = hv_fetch(tmp->hv, "underlying_types", strlen("underlying_types"), 0);
    av = (AV *)SvRV(*svp);
    svp = av_fetch(av, j, 0);
    if(sv_derived_from(*svp, "FFI::Platypus::Type::FFI"))
    {
      ffi = INT2PTR(ffi_type *, SvIV((SV*)SvRV(*svp)));

      argument_types[n+j] = SvREFCNT_inc(arg_type);
      ffi_argument_types[n+j] = ffi;
    }
    else if(sv_derived_from(*svp, "FFI::Platypus::Type::Array"))
    {
      ffi = &ffi_type_pointer;

      argument_types[n+j] = SvREFCNT_inc(arg_type);
      ffi_argument_types[n+j] = ffi;
    }
    else if(sv_derived_from(*svp, "FFI::Platypus::Type::CustomPerl"))
    {
      int d2 = ffi_pl_prepare_customperl(argument_types, ffi_argument_types, n+j, *svp)-1;

      d += d2;
      j += d2-1;
    }
    else
    {
      ffi = SV2ffi_pl_type(*svp)->ffi_type;

      argument_types[n+j] = SvREFCNT_inc(arg_type);
      ffi_argument_types[n+j] = ffi;
    }
  }

  return d+1;
}

int
ffi_pl_arguments_set_record(ffi_pl_arguments *arguments, int i, SV *type_sv, SV *arg)
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
ffi_pl_arguments_set_perl_string(ffi_pl_arguments *arguments, int i, SV *type_sv, SV *arg)
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
ffi_pl_arguments_set_ref(ffi_pl_arguments *arguments, int i, SV *type_sv, SV *arg)
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
ffi_pl_arguments_set_closure(ffi_pl_arguments *arguments, int i, SV *type_sv, SV *arg)
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

/* Local Variables: */
/* c-basic-offset: 2 */
/* c-file-style: "linux" */
/* End: */
