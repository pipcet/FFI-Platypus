#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"

#include "ffi_platypus.h"
#include "ffi_platypus_guts.h"

extern ffi_pl_rtypes_arguments *current_argv;

int
ffi_pl_rtypes_arguments_set_ffi_void(ffi_pl_rtypes_arguments *arguments, int i, SV *arg_type, void *extra_data, SV *arg, SV **freeme)
{
  return 1;
}

int
ffi_pl_rtypes_arguments_set_ffi_uint8(ffi_pl_rtypes_arguments *arguments, int i, SV *arg_type, void *extra_data, SV *arg, SV **freeme)
{
  ffi_pl_rtypes_arguments_set_uint8(arguments, i, SvOK(arg) ? SvUV(arg) : 0);

  return 1;
}

int
ffi_pl_rtypes_arguments_set_ffi_sint8(ffi_pl_rtypes_arguments *arguments, int i, SV *arg_type, void *extra_data, SV *arg, SV **freeme)
{
  ffi_pl_rtypes_arguments_set_uint8(arguments, i, SvOK(arg) ? SvIV(arg) : 0);

  return 1;
}

int
ffi_pl_rtypes_arguments_set_ffi_uint16(ffi_pl_rtypes_arguments *arguments, int i, SV *arg_type, void *extra_data, SV *arg, SV **freeme)
{
  ffi_pl_rtypes_arguments_set_uint16(arguments, i, SvOK(arg) ? SvUV(arg) : 0);

  return 1;
}

int
ffi_pl_rtypes_arguments_set_ffi_sint16(ffi_pl_rtypes_arguments *arguments, int i, SV *arg_type, void *extra_data, SV *arg, SV **freeme)
{
  ffi_pl_rtypes_arguments_set_sint16(arguments, i, SvOK(arg) ? SvIV(arg) : 0);

  return 1;
}

int
ffi_pl_rtypes_arguments_set_ffi_uint32(ffi_pl_rtypes_arguments *arguments, int i, SV *arg_type, void *extra_data, SV *arg, SV **freeme)
{
  ffi_pl_rtypes_arguments_set_uint32(arguments, i, SvOK(arg) ? SvUV(arg) : 0);

  return 1;
}

int
ffi_pl_rtypes_arguments_set_ffi_sint32(ffi_pl_rtypes_arguments *arguments, int i, SV *arg_type, void *extra_data, SV *arg, SV **freeme)
{
  ffi_pl_rtypes_arguments_set_sint32(arguments, i, SvOK(arg) ? SvIV(arg) : 0);

  return 1;
}

int
ffi_pl_rtypes_arguments_set_ffi_uint64(ffi_pl_rtypes_arguments *arguments, int i, SV *arg_type, void *extra_data, SV *arg, SV **freeme)
{
#ifdef HAVE_IV_IS_64
  ffi_pl_rtypes_arguments_set_uint64(arguments, i, SvOK(arg) ? SvUV(arg) : 0);
#else
  ffi_pl_rtypes_arguments_set_uint64(arguments, i, SvOK(arg) ? SvU64(arg) : 0);
#endif

  return 1;
}

int
ffi_pl_rtypes_arguments_set_ffi_sint64(ffi_pl_rtypes_arguments *arguments, int i, SV *arg_type, void *extra_data, SV *arg, SV **freeme)
{
#ifdef HAVE_IV_IS_64
  ffi_pl_rtypes_arguments_set_sint64(arguments, i, SvOK(arg) ? SvIV(arg) : 0);
#else
  ffi_pl_rtypes_arguments_set_sint64(arguments, i, SvOK(arg) ? SvI64(arg) : 0);
#endif

  return 1;
}

int
ffi_pl_rtypes_arguments_set_ffi_float(ffi_pl_rtypes_arguments *arguments, int i, SV *arg_type, void *extra_data, SV *arg, SV **freeme)
{
  ffi_pl_rtypes_arguments_set_float(arguments, i, SvOK(arg) ? SvNV(arg) : 0.0);

  return 1;
}

int
ffi_pl_rtypes_arguments_set_ffi_double(ffi_pl_rtypes_arguments *arguments, int i, SV *arg_type, void *extra_data, SV *arg, SV **freeme)
{
  ffi_pl_rtypes_arguments_set_double(arguments, i, SvOK(arg) ? SvNV(arg) : 0.0);

  return 1;
}

int
ffi_pl_rtypes_arguments_set_ffi_pointer(ffi_pl_rtypes_arguments *arguments, int i, SV *arg_type, void *extra_data, SV *arg, SV **freeme)
{
  ffi_pl_rtypes_arguments_set_pointer(arguments, i, SvOK(arg) ? INT2PTR(void*, SvIV(arg)) : NULL);

  return 1;
}

int
ffi_pl_rtypes_arguments_set_ffi(ffi_pl_rtypes_arguments *arguments, int i, SV *arg_type, void *extra_data, SV *arg, SV **freeme)
{
  ffi_type *ffi = INT2PTR(ffi_type *, SvIV((SV *) SvRV(arg_type)));

  switch(ffi->type)
  {
  case FFI_TYPE_UINT8:
    ffi_pl_rtypes_arguments_set_uint8(arguments, i, SvOK(arg) ? SvUV(arg) : 0);
    break;
  case FFI_TYPE_SINT8:
    ffi_pl_rtypes_arguments_set_sint8(arguments, i, SvOK(arg) ? SvIV(arg) : 0);
    break;
  case FFI_TYPE_UINT16:
    ffi_pl_rtypes_arguments_set_uint16(arguments, i, SvOK(arg) ? SvUV(arg) : 0);
    break;
  case FFI_TYPE_SINT16:
    ffi_pl_rtypes_arguments_set_sint16(arguments, i, SvOK(arg) ? SvIV(arg) : 0);
    break;
  case FFI_TYPE_UINT32:
    ffi_pl_rtypes_arguments_set_uint32(arguments, i, SvOK(arg) ? SvUV(arg) : 0);
    break;
  case FFI_TYPE_SINT32:
    ffi_pl_rtypes_arguments_set_sint32(arguments, i, SvOK(arg) ? SvIV(arg) : 0);
    break;
#ifdef HAVE_IV_IS_64
  case FFI_TYPE_UINT64:
    ffi_pl_rtypes_arguments_set_uint64(arguments, i, SvOK(arg) ? SvUV(arg) : 0);
    break;
  case FFI_TYPE_SINT64:
    ffi_pl_rtypes_arguments_set_sint64(arguments, i, SvOK(arg) ? SvIV(arg) : 0);
    break;
#else
  case FFI_TYPE_UINT64:
    ffi_pl_rtypes_arguments_set_uint64(arguments, i, SvOK(arg) ? SvU64(arg) : 0);
    break;
  case FFI_TYPE_SINT64:
    ffi_pl_rtypes_arguments_set_sint64(arguments, i, SvOK(arg) ? SvI64(arg) : 0);
    break;
#endif
  case FFI_TYPE_FLOAT:
    ffi_pl_rtypes_arguments_set_float(arguments, i, SvOK(arg) ? SvNV(arg) : 0.0);
    break;
  case FFI_TYPE_DOUBLE:
    ffi_pl_rtypes_arguments_set_double(arguments, i, SvOK(arg) ? SvNV(arg) : 0.0);
    break;
  case FFI_TYPE_POINTER:
    ffi_pl_rtypes_arguments_set_pointer(arguments, i, SvOK(arg) ? INT2PTR(void*, SvIV(arg)) : NULL);
    break;
  default:
    warn("argument type not supported (%d)", i);
    break;
  }

  return 1;
}

int
ffi_pl_rtypes_arguments_set_array(ffi_pl_rtypes_arguments *arguments, int i, SV *type_sv, void *extra_data, SV *arg, SV **freeme)
{
  void *ptr;
  ffi_pl_rtypes_type *type = extra_data;
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
  ffi_pl_rtypes_arguments_set_pointer(arguments, i, ptr);

  return 1;
}

int
ffi_pl_rtypes_arguments_set_customperl(ffi_pl_rtypes_arguments *arguments, int i, SV *type_sv, void *extra_data, SV *arg, SV **freeme)
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

  arg2 = ffi_pl_rtypes_custom_array_perl(
    perl_to_native_sv,
    arg,
    i
  );

  if(arg2 != NULL && SvROK(arg2) && SvTYPE(SvRV(arg2)) == SVt_PVAV) {
    int j, perl_j;
    AV *type_av;
    int type_len, arg2_len;
    int native_count;

    svp = hv_fetch(hv, "underlying_types", strlen("underlying_types"), 0);
    type_av = (AV *)SvRV(*svp);
    type_len = av_len(type_av) + 1;

    arg2_len = av_len((AV*)SvRV(arg2)) + 1;
    for(j=0,perl_j=0; j<arg2_len; j++,perl_j++) {
      svp = av_fetch(type_av, perl_j, 0);
      {
	dSP;
	int count;

	ENTER;
	SAVETMPS;
	PUSHMARK(SP);
	XPUSHs(*svp);
	PUTBACK;

	count = call_method("count_native_arguments", G_SCALAR);

	SPAGAIN;

	if(count == 1)
	  native_count = POPi;

	PUTBACK;
	FREETMPS;
	LEAVE;
      }

#ifdef FFI_PL_PROBE_RUNTIMESIZEDARRAYS
      ffi_pl_rtypes_getter getters[type_len];
      ffi_type *ffi[native_count];
#else
      ffi_pl_rtypes_getter **getters;
      ffi_type **ffi;

      Newx(getters, type_len, ffi_pl_rtypes_getter *);
      Newx(ffi, native_count, ffi_type *);
#endif

      getters[0].sv = *svp;
      getters[0].perl_args = 1;
      getters[0].native_args = 1;
      getters[0].stack_args = 0;

      getters[0].extra_data = ffi_pl_rtypes_extra_data(*svp);
      getters[0].perl_to_native = (perl_to_native_pointer_t) ffi_pl_rtypes_arguments_perl_to_native(*svp, ffi_pl_rtypes_extra_data(*svp));

      int k = ffi_pl_rtypes_prepare_any(getters, getters+type_len, &ffi[0], &ffi[native_count],
					*svp, ffi_pl_rtypes_extra_data(*svp));

      STRLEN len;
      const char *name;
      SV *arg3;
      SV *type2_sv;
      ffi_pl_rtypes_getter *getter;
      /* when not enough return types are present, we assume the last
       * type repeats indefinitely for the remaining arguments. */
      getter = &getters[j<type_len ? j : type_len - 1, 0];

      svp = av_fetch(type_av, j<type_len ? j : type_len - 1, 0);
      type2_sv = *svp;

      int in_argument_count = getter->perl_args;
      if(in_argument_count > 1) {
	AV *av = newAV();

	for(n=0; n<in_argument_count; n++) {
	  svp = av_fetch((AV*)SvRV(arg2), perl_j, 0);
	  av_push(av, SvREFCNT_inc(*svp));
	  perl_j++;
	}
	perl_j--;

	arg3 = (SV*)av;
      } else {
	svp = av_fetch((AV*)SvRV(arg2), perl_j, 0);

	arg3 = *svp;
      }
      if(!SvROK(type2_sv)) {
	croak("oh no");
      }

      i += getter->perl_to_native(arguments, i, getter->sv, getter->extra_data, arg3, freeme);
    }

    if (!*freeme)
    {
      *freeme = newRV_noinc((SV*)newAV());
    }

    av_push((AV*)SvRV(*freeme), arg2);

    return i - orig_i;
  }
  else if (arg2 != NULL)
  {
    croak("invalid argument returned from Perl handler");
  }

  svp = hv_fetch(hv, "argument_count", strlen("argument_count"), 0);
  if (svp) {
    return SvIV(*svp) + 1;
  }

  return 1;
}

int
ffi_pl_rtypes_arguments_set_constant(ffi_pl_rtypes_arguments *arguments, int i, SV *type_sv, void *extra_data, SV *arg, SV **freeme)
{
  HV *hv = (HV*)SvRV(type_sv);
  SV **svp;
  SV *value = NULL;
  int n;
  int orig_i = i;

  svp = hv_fetch(hv, "value", strlen("value"), 0);
  if (svp) {
    value = SvREFCNT_inc(*svp);
  }

  int j=0;
  AV *type_av;
  svp = hv_fetch(hv, "underlying_types", strlen("underlying_types"), 0);
  type_av = (AV *)SvRV(*svp);
  svp = av_fetch(type_av, j, 0);
  i += ffi_pl_rtypes_arguments_set_any(arguments, i, *svp, ffi_pl_rtypes_extra_data(*svp), value, freeme);

  if (!*freeme)
  {
    *freeme = newRV_noinc((SV*)newAV());
  }

  av_push((AV*)SvRV(*freeme), value);

  return i - orig_i;
}

int ffi_pl_rtypes_prepare_ffi(ffi_pl_rtypes_getter *getters, ffi_pl_rtypes_getter *getters_limit, ffi_type **ffi_argument_types, ffi_type **ffi_argument_types_limit, SV *arg_type, void *extra_data)
{
  if(ffi_argument_types != ffi_argument_types_limit)
    *ffi_argument_types = INT2PTR(ffi_type *, SvIV((SV*)SvRV(arg_type)));
  else
    return -1;

  return 1;
}

int ffi_pl_rtypes_prepare_array(ffi_pl_rtypes_getter *getters, ffi_pl_rtypes_getter *getters_limit, ffi_type **ffi_argument_types, ffi_type **ffi_argument_types_limit, SV *arg_type, void *extra_data)
{
  if(ffi_argument_types != ffi_argument_types_limit)
    *ffi_argument_types = &ffi_type_pointer;
  else
    return -1;

  return 1;
}

int ffi_pl_rtypes_prepare_sv(ffi_pl_rtypes_getter *getters, ffi_pl_rtypes_getter *getters_limit, ffi_type **ffi_argument_types, ffi_type **ffi_argument_types_limit, SV *arg_type, void *extra_data)
{
  if(ffi_argument_types != ffi_argument_types_limit)
    *ffi_argument_types = &ffi_type_pointer;
  else
    return -1;

  return 1;
}

int ffi_pl_rtypes_prepare_closure(ffi_pl_rtypes_getter *getters, ffi_pl_rtypes_getter *getters_limit, ffi_type **ffi_argument_types, ffi_type **ffi_argument_types_limit, SV *arg_type, void *extra_data)
{
  if(ffi_argument_types != ffi_argument_types_limit)
    *ffi_argument_types = &ffi_type_pointer;
  else
    return -1;

  return 1;
}

int ffi_pl_rtypes_prepare_string(ffi_pl_rtypes_getter *getters, ffi_pl_rtypes_getter *getters_limit, ffi_type **ffi_argument_types, ffi_type **ffi_argument_types_limit, SV *arg_type, void *extra_data)
{
  if(ffi_argument_types != ffi_argument_types_limit)
    *ffi_argument_types = &ffi_type_pointer;
  else
    return -1;

  return 1;
}

int ffi_pl_rtypes_prepare_generic(ffi_pl_rtypes_getter *getters, ffi_pl_rtypes_getter *getters_limit, ffi_type **ffi_argument_types, ffi_type **ffi_argument_types_limit, SV *arg_type, void *extra_data)
{
  if(ffi_argument_types != ffi_argument_types_limit)
    *ffi_argument_types = &ffi_type_pointer;

  else
    return -1;

  return 1;
}

int (*ffi_pl_rtypes_prepare(SV *arg_type, void *extra_data))(ffi_pl_rtypes_getter *getters, ffi_pl_rtypes_getter *getters_limit, ffi_type **ffi_argument_types, ffi_type **ffi_argument_types_limit, SV *arg_type, void *extra_data)
{
  dSP;

  int count;
  void *out_arg;

  ENTER;
  SAVETMPS;
  PUSHMARK(SP);
  XPUSHs(arg_type);
  PUTBACK;

  count = call_method("prepare_pointer", G_SCALAR);

  SPAGAIN;

  if(count == 1)
    out_arg = INT2PTR(void *, SvRV(POPs));
  else
    out_arg = NULL;

  PUTBACK;
  FREETMPS;
  LEAVE;

  return out_arg;
}

int ffi_pl_rtypes_prepare_any(ffi_pl_rtypes_getter *getters, ffi_pl_rtypes_getter *getters_limit, ffi_type **ffi_argument_types, ffi_type **ffi_argument_types_limit, SV *arg_type, void *extra_data)
{
  return ffi_pl_rtypes_prepare(arg_type, extra_data)(getters, getters_limit, ffi_argument_types, ffi_argument_types_limit, arg_type, extra_data);
}

int ffi_pl_rtypes_prepare_customperl(ffi_pl_rtypes_getter *getters, ffi_pl_rtypes_getter *getters_limit, ffi_type **ffi_argument_types, ffi_type **ffi_argument_types_limit, SV *arg_type, void *extra_data)
{
  HV *hv = (HV*)SvRV(arg_type);
  SV **svp;
  int d=0;
  int j;
  int perl_j;
  ffi_pl_rtypes_type *tmp = extra_data;

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
    int d2 = ffi_pl_rtypes_prepare_any(NULL, NULL, ffi_argument_types+j, ffi_argument_types_limit, *svp, ffi_pl_rtypes_extra_data(*svp));
    d += d2-1;
    j += d2-1;
  }

  if(getters != getters_limit)
  {
    getters->native_args = d+1;

    svp = hv_fetch(hv, "in_argument_count", strlen("in_argument_count"), 0);
    if(svp)
    {
      getters->perl_args = SvIV(*svp);
    }
    else
    {
      getters->perl_args = 1;
    }
  }

  return d+1;
}

int
ffi_pl_rtypes_arguments_set_record(ffi_pl_rtypes_arguments *arguments, int i, SV *type_sv, void *extra_data, SV *arg, SV **freeme)
{
  ffi_pl_rtypes_type *type = extra_data;
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
  ffi_pl_rtypes_arguments_set_pointer(arguments, i, ptr);

  return 1;
}

int
ffi_pl_rtypes_arguments_set_perl_string_variable(ffi_pl_rtypes_arguments *arguments, int i, SV *type_sv, void *extra_data, SV *arg, SV **freeme)
{
  ffi_pl_rtypes_arguments_set_string(arguments, i, SvOK(arg) ? SvPV_nolen(arg) : NULL);

  return 1;
}

int
ffi_pl_rtypes_arguments_set_perl_string(ffi_pl_rtypes_arguments *arguments, int i, SV *type_sv, void *extra_data, SV *arg, SV **freeme)
{
  ffi_pl_rtypes_type *type = extra_data;

  switch(type->extra[0].string.platypus_string_type)
  {
  case FFI_PL_STRING_RW:
  case FFI_PL_STRING_RO:
    ffi_pl_rtypes_arguments_set_string(arguments, i, SvOK(arg) ? SvPV_nolen(arg) : NULL);
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
      ffi_pl_rtypes_arguments_set_pointer(arguments, i, ptr);
    }
    break;
  }

  return 1;
}

int
ffi_pl_rtypes_arguments_set_ref_sint32(ffi_pl_rtypes_arguments *arguments, int i, SV *type_sv, void *extra_data, SV *arg, SV **freeme)
{
  ffi_pl_argument *ptrarg = arguments->pointers[i];
  ffi_pl_argument *stackarg = ptrarg + 1;

  ffi_pl_rtypes_arguments_set_pointer(arguments, i, NULL);

  if(SvROK(arg)) /* TODO: and a scalar ref */
  {
    SV *arg2 = SvRV(arg);
    if(SvTYPE(arg2) < SVt_PVAV)
    {
      stackarg->sint32 = SvOK(arg2) ? SvUV(arg2) : 0;
      ffi_pl_rtypes_arguments_set_pointer(arguments, i, &stackarg->sint32);
    }
    else
    {
      warn("argument type not a reference to scalar (%d)", i);
    }
  }

  return 1;
}

int
ffi_pl_rtypes_arguments_set_ref(ffi_pl_rtypes_arguments *arguments, int i, SV *type_sv, void *extra_data, SV *arg, SV **freeme)
{
  ffi_pl_rtypes_type *type = extra_data;
  void *ptr;

  if(SvROK(arg)) /* TODO: and a scalar ref */
  {
    SV *arg2 = SvRV(arg);
    if(SvTYPE(arg2) < SVt_PVAV)
    {
      switch(type->ffi_type->type)
      {
      case FFI_TYPE_UINT8:
	Newx(ptr, 1, uint8_t);
	*((uint8_t*)ptr) = SvOK(arg2) ? SvUV(arg2) : 0;
	break;
      case FFI_TYPE_SINT8:
	Newx(ptr, 1, int8_t);
	*((int8_t*)ptr) = SvOK(arg2) ? SvIV(arg2) : 0;
	break;
      case FFI_TYPE_UINT16:
	Newx(ptr, 1, uint16_t);
	*((uint16_t*)ptr) = SvOK(arg2) ? SvUV(arg2) : 0;
	break;
      case FFI_TYPE_SINT16:
	Newx(ptr, 1, int16_t);
	*((int16_t*)ptr) = SvOK(arg2) ? SvIV(arg2) : 0;
	break;
      case FFI_TYPE_UINT32:
	Newx(ptr, 1, uint32_t);
	*((uint32_t*)ptr) = SvOK(arg2) ? SvUV(arg2) : 0;
	break;
      case FFI_TYPE_SINT32:
	Newx(ptr, 1, int32_t);
	*((int32_t*)ptr) = SvOK(arg2) ? SvIV(arg2) : 0;
	break;
      case FFI_TYPE_UINT64:
	Newx(ptr, 1, uint64_t);
#ifdef HAVE_IV_IS_64
	*((uint64_t*)ptr) = SvOK(arg2) ? SvUV(arg2) : 0;
#else
	*((uint64_t*)ptr) = SvOK(arg2) ? SvU64(arg2) : 0;
#endif
	break;
      case FFI_TYPE_SINT64:
	Newx(ptr, 1, int64_t);
#ifdef HAVE_IV_IS_64
	*((int64_t*)ptr) = SvOK(arg2) ? SvIV(arg2) : 0;
#else
	*((int64_t*)ptr) = SvOK(arg2) ? SvI64(arg2) : 0;
#endif
	break;
      case FFI_TYPE_FLOAT:
	Newx(ptr, 1, float);
	*((float*)ptr) = SvOK(arg2) ? SvNV(arg2) : 0.0;
	break;
      case FFI_TYPE_DOUBLE:
	Newx(ptr, 1, double);
	*((double*)ptr) = SvOK(arg2) ? SvNV(arg2) : 0.0;
	break;
      case FFI_TYPE_POINTER:
	Newx(ptr, 1, void*);
	{
	  SV *tmp = SvRV(arg);
	  *((void**)ptr) = SvOK(tmp) ? INT2PTR(void *, SvIV(tmp)) : NULL;
	}
	break;
#ifdef FFI_PL_PROBE_LONGDOUBLE
      case FFI_TYPE_LONGDOUBLE:
	Newx(ptr, 1, long double);
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
  ffi_pl_rtypes_arguments_set_pointer(arguments, i, ptr);

  return 1;
}

int
ffi_pl_rtypes_arguments_set_closure(ffi_pl_rtypes_arguments *arguments, int i, SV *type_sv, void *extra_data, SV *arg, SV **freeme)
{
  if(!SvROK(arg))
  {
    ffi_pl_rtypes_arguments_set_pointer(arguments, i, SvOK(arg) ? INT2PTR(void*, SvIV(arg)) : NULL);

    return 1;
  }
  else
  {
    ffi_pl_rtypes_closure *closure;
    ffi_status ffi_status;
    ffi_pl_rtypes_type *type = extra_data;

    SvREFCNT_inc(arg);

    closure = ffi_pl_rtypes_closure_get_data(arg, type_sv);
    if(closure != NULL)
    {
      ffi_pl_rtypes_arguments_set_pointer(arguments, i, closure->function_pointer);
    }
    else
    {
      Newx(closure, 1, ffi_pl_rtypes_closure);
      closure->ffi_closure = ffi_closure_alloc(sizeof(ffi_closure), &closure->function_pointer);
      if(closure->ffi_closure == NULL)
      {
	Safefree(closure);
	ffi_pl_rtypes_arguments_set_pointer(arguments, i, NULL);
	warn("unable to allocate memory for closure");
      }
      else
      {
	ffi_cif *cif;
	SV **svp;

	svp = hv_fetch(type->hv, "ffi_cif", strlen("ffi_cif"), 0);
	cif = (ffi_cif *)SvPVX(*svp);
	closure->type = type_sv;

	ffi_status = ffi_prep_closure_loc(
	  closure->ffi_closure,
	  cif,
	  ffi_pl_rtypes_closure_call,
	  closure,
	  closure->function_pointer
	);

	if(ffi_status != FFI_OK)
	{
	  ffi_closure_free(closure->ffi_closure);
	  Safefree(closure);
	  ffi_pl_rtypes_arguments_set_pointer(arguments, i, NULL);
	  warn("unable to create closure");
	}
	else
	{
	  SV **svp;
	  SV **hvp;
	  SV *keysv;
	  const char *key;
	  STRLEN len;

	  closure->coderef = SvRV(arg);
	  keysv = ffi_pl_rtypes_closure_add_data(arg, closure->type, closure);
	  key = SvPV(keysv, len);
	  hvp = hv_fetch((HV *)closure->coderef, "cbdata", 6, 0);
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
	  ffi_pl_rtypes_arguments_set_pointer(arguments, i, closure->function_pointer);
	  SvREFCNT_dec(keysv);
	}
      }
    }
  }

  return 1;
}

int
ffi_pl_rtypes_arguments_set_exoticfloat(ffi_pl_rtypes_arguments *arguments, int i, SV *type_sv, void *extra_data, SV *arg, SV **freeme)
{
  ffi_pl_rtypes_type *type = extra_data;

  switch(type->ffi_type->type)
  {
#ifdef FFI_PL_PROBE_LONGDOUBLE
  case FFI_TYPE_LONGDOUBLE:
  {
    long double *ptr;
    Newx(ptr, 1, long double);
    arguments->pointers[i] = (void *)ptr;
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
      Newx(ptr, 2, float);
      arguments->pointers[i] = (void *)ptr;
      ffi_pl_perl_complex_float(arg, ptr);
    }
    break;
    case 16:
    {
      double *ptr;
      Newx(ptr, 2, double);
      arguments->pointers[i] = (void *)ptr;
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

perl_to_native_pointer_t
ffi_pl_rtypes_arguments_perl_to_native(SV *type_sv, void *extra_data)
{
  dSP;

  int count;
  void *out_arg;

  ENTER;
  SAVETMPS;
  PUSHMARK(SP);
  XPUSHs(type_sv);
  PUTBACK;

  count = call_method("perl_to_native_pointer", G_SCALAR);

  SPAGAIN;

  if(count == 1)
    out_arg = INT2PTR(void *, SvIVX(POPs));
  else
    out_arg = NULL;

  PUTBACK;
  FREETMPS;
  LEAVE;

  return out_arg;
}

int
ffi_pl_rtypes_arguments_set_any(ffi_pl_rtypes_arguments *arguments, int i, SV *type_sv, void *extra_data, SV *arg, SV **freeme)
{
  ffi_pl_rtypes_getter getter;
  getter.sv = arg;
  getter.perl_args = 1;
  getter.native_args = 1;
  getter.perl_to_native = ffi_pl_rtypes_arguments_perl_to_native(type_sv, extra_data);

  return getter.perl_to_native(arguments, i, type_sv, ffi_pl_rtypes_extra_data(type_sv), arg, freeme);
}

int
ffi_pl_rtypes_arguments_set_ref_post_sint32(ffi_pl_rtypes_arguments *arguments, int i, SV *type_sv, void *extra_data, SV *arg, SV **freeme)
{
  void *ptr = ffi_pl_rtypes_arguments_get_pointer(arguments, i-1);
  if(ptr != NULL)
  {
    if(!SvREADONLY(SvRV(arg)))
    {
      sv_setiv(SvRV(arg), *((int32_t*)ptr));
    }
  }

  return 1;
}

int
ffi_pl_rtypes_arguments_set_ref_post(ffi_pl_rtypes_arguments *arguments, int i, SV *type_sv, void *extra_data, SV *arg, SV **freeme)
{
  ffi_pl_rtypes_type *type = extra_data;
  void *ptr = ffi_pl_rtypes_arguments_get_pointer(arguments, i-1);
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
  Safefree(ptr);

  return 1;
}

int
ffi_pl_rtypes_arguments_set_array_post(ffi_pl_rtypes_arguments *arguments, int i, SV *type_sv, void *extra_data, SV *arg, SV **freeme)
{
  ffi_pl_rtypes_type *type = extra_data;
  void *ptr = ffi_pl_rtypes_arguments_get_pointer(arguments, i-1);
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
  Safefree(ptr);

  return 1;
}

int
ffi_pl_rtypes_arguments_set_closure_post(ffi_pl_rtypes_arguments *arguments, int i, SV *type_sv, void *extra_data, SV *arg, SV **freeme)
{
  if(SvROK(arg))
  {
    SvREFCNT_dec(arg);
  }

  return 1;
}

int
ffi_pl_rtypes_arguments_set_custom_perl_post(ffi_pl_rtypes_arguments *arguments, int i, SV *type_sv, void *extra_data, SV *arg, SV **freeme)
{
  HV *hv = (HV*)SvRV(type_sv);
  SV **svp;
  SV *arg2 = NULL;
  int native_count=0;
  int n;

  {
    dSP;
    int count;

    ENTER;
    SAVETMPS;
    PUSHMARK(SP);
    XPUSHs(type_sv);
    PUTBACK;

    count = call_method("count_native_arguments", G_SCALAR);

    SPAGAIN;

    if(count == 1)
      native_count = POPi;

    PUTBACK;
    FREETMPS;
    LEAVE;
  }
  i -= native_count;

  svp = hv_fetch(hv, "perl_to_native_post", strlen("perl_to_native_post"), 0);
  if (svp) {
    SV *perl_to_native_post_sv = *svp;

    ffi_pl_rtypes_custom_perl_cb(perl_to_native_post_sv, arg, i);
  }

  return native_count;
}

int
ffi_pl_rtypes_arguments_set_exoticfloat_post(ffi_pl_rtypes_arguments *arguments, int i, SV *type_sv, void *extra_data, SV *arg, SV **freeme)
{
  void *ptr = arguments->pointers[i-1];
  Safefree(ptr);

  return 1;
}

int
ffi_pl_rtypes_sv_perl_to_native(ffi_pl_rtypes_arguments *arguments, int i, SV *type_sv, void *extra_data, SV *arg, SV **freeme)
{
  SvREFCNT_inc(arg);

  arguments->pointers[i]->pointer = arg;

  return 1;
}

int
ffi_pl_rtypes_sv_perl_to_native_post(ffi_pl_rtypes_arguments *arguments, int i, SV *type_sv, void *extra_data, SV *arg, SV **freeme)
{
  SvREFCNT_inc(arg);

  return 1;
}

perl_to_native_pointer_t
ffi_pl_rtypes_arguments_perl_to_native_post(SV *type_sv, void *extra_data)
{
  dSP;

  int count;
  void *out_arg;

  ENTER;
  SAVETMPS;
  PUSHMARK(SP);
  XPUSHs(type_sv);
  PUTBACK;

  count = call_method("perl_to_native_post_pointer", G_SCALAR);

  SPAGAIN;

  if(count == 1)
    out_arg = INT2PTR(void *, SvIVX(POPs));
  else
    out_arg = NULL;

  PUTBACK;
  FREETMPS;
  LEAVE;

  return out_arg;
}


SV *
ffi_pl_rtypes_native_to_perl_ffi_uint8(SV *targ, ffi_pl_result *result, SV *return_type, void *extra_data)
{
#ifdef FFI_PL_PROBE_BIGENDIAN
  return sv_2mortal(newSVuv(result->uint8_array[3]));
#else
  return sv_2mortal(newSVuv(result->uint8));
#endif
}

SV *
ffi_pl_rtypes_native_to_perl_ffi_sint8(SV *targ, ffi_pl_result *result, SV *return_type, void *extra_data)
{
#ifdef FFI_PL_PROBE_BIGENDIAN
  return sv_2mortal(newSViv(result->sint8_array[3]));
#else
  return sv_2mortal(newSViv(result->sint8));
#endif
}

SV *
ffi_pl_rtypes_native_to_perl_ffi_uint16(SV *targ, ffi_pl_result *result, SV *return_type, void *extra_data)
{
#ifdef FFI_PL_PROBE_BIGENDIAN
  return sv_2mortal(newSVuv(result->uint16_array[1]));
#else
  return sv_2mortal(newSVuv(result->uint16));
#endif
}

SV *
ffi_pl_rtypes_native_to_perl_ffi_sint16(SV *targ, ffi_pl_result *result, SV *return_type, void *extra_data)
{
#ifdef FFI_PL_PROBE_BIGENDIAN
  return sv_2mortal(newSViv(result->sint16_array[1]));
#else
  return sv_2mortal(newSViv(result->sint16));
#endif
}

SV *
ffi_pl_rtypes_native_to_perl_ffi_uint32(SV *targ, ffi_pl_result *result, SV *return_type, void *extra_data)
{
  return sv_2mortal(newSVuv(result->uint32));
}

SV *
ffi_pl_rtypes_native_to_perl_ffi_sint32(SV *targ, ffi_pl_result *result, SV *return_type, void *extra_data)
{
  sv_setiv(targ, (IV)(result->sint32));
  return targ;
}

SV *
ffi_pl_rtypes_native_to_perl_ffi_uint64(SV *targ, ffi_pl_result *result, SV *return_type, void *extra_data)
{
#ifdef HAVE_IV_IS_64
  return sv_2mortal(newSVuv(result->uint64));
#else
  {
    SV *ret = sv_newmortal();
    sv_setu64(ret, result->uint64);
    return ret;
  }
#endif
}

SV *
ffi_pl_rtypes_native_to_perl_ffi_sint64(SV *targ, ffi_pl_result *result, SV *return_type, void *extra_data)
{
#ifdef HAVE_IV_IS_64
  return sv_2mortal(newSViv(result->sint64));
#else
  {
    SV *ret = sv_newmortal();
    sv_seti64(ST(0), result->sint64);
    return ret;
  }
#endif
}

SV *
ffi_pl_rtypes_native_to_perl_ffi_float(SV *targ, ffi_pl_result *result, SV *return_type, void *extra_data)
{
  return sv_2mortal(newSVnv(result->xfloat));
}

SV *
ffi_pl_rtypes_native_to_perl_ffi_double(SV *targ, ffi_pl_result *result, SV *return_type, void *extra_data)
{
  return sv_2mortal(newSVnv(result->xdouble));
}

SV *
ffi_pl_rtypes_native_to_perl_ffi_pointer(SV *targ, ffi_pl_result *result, SV *return_type, void *extra_data)
{
  if(result->pointer == NULL)
    return NULL;

  return sv_2mortal(newSViv(PTR2IV(result->pointer)));
}

SV *
ffi_pl_rtypes_native_to_perl_void(SV *targ, ffi_pl_result *result, SV *return_type, void *extra_data)
{
  return NULL;
}

SV *
ffi_pl_rtypes_native_to_perl_string_variable(SV *targ, ffi_pl_result *result, SV *return_type, void *extra_data)
{
  if(result->pointer == NULL)
  {
    return NULL;
  }
  else
  {
    return sv_2mortal(newSVpv(result->pointer, 0));
  }
}

SV *
ffi_pl_rtypes_native_to_perl_string(SV *targ, ffi_pl_result *result, SV *return_type, void *extra_data)
{
  if(result->pointer == NULL)
  {
    return NULL;
  }
  else
  {
    ffi_pl_rtypes_type *pl_return_type = extra_data;

    if(pl_return_type->extra[0].string.platypus_string_type == FFI_PL_STRING_FIXED)
    {
      SV *value = sv_newmortal();
      sv_setpvn(value, result->pointer, pl_return_type->extra[0].string.size);
      return value;
    }
    else
    {
      return sv_2mortal(newSVpv(result->pointer, 0));
    }
  }
}

SV *
ffi_pl_rtypes_native_to_perl_pointer(SV *targ, ffi_pl_result *result, SV *return_type, void *extra_data)
{
  ffi_pl_rtypes_type *pl_return_type = extra_data;
  if(result->pointer == NULL)
  {
    return NULL;
  }
  else
  {
    SV *value;
    switch(pl_return_type->ffi_type->type)
    {
    case FFI_TYPE_UINT8:
      value = sv_newmortal();
      sv_setuv(value, *((uint8_t*) result->pointer));
      break;
    case FFI_TYPE_SINT8:
      value = sv_newmortal();
      sv_setiv(value, *((int8_t*) result->pointer));
      break;
    case FFI_TYPE_UINT16:
      value = sv_newmortal();
      sv_setuv(value, *((uint16_t*) result->pointer));
      break;
    case FFI_TYPE_SINT16:
      value = sv_newmortal();
      sv_setiv(value, *((int16_t*) result->pointer));
      break;
    case FFI_TYPE_UINT32:
      value = sv_newmortal();
      sv_setuv(value, *((uint32_t*) result->pointer));
      break;
    case FFI_TYPE_SINT32:
      value = sv_newmortal();
      sv_setiv(value, *((int32_t*) result->pointer));
      break;
    case FFI_TYPE_UINT64:
      value = sv_newmortal();
#ifdef HAVE_IV_IS_64
      sv_setuv(value, *((uint64_t*) result->pointer));
#else
      sv_seti64(value, *((int64_t*) result->pointer));
#endif
      break;
    case FFI_TYPE_SINT64:
      value = sv_newmortal();
#ifdef HAVE_IV_IS_64
      sv_setiv(value, *((int64_t*) result->pointer));
#else
      sv_seti64(value, *((int64_t*) result->pointer));
#endif
      break;
    case FFI_TYPE_FLOAT:
      value = sv_newmortal();
      sv_setnv(value, *((float*) result->pointer));
      break;
    case FFI_TYPE_DOUBLE:
      value = sv_newmortal();
      sv_setnv(value, *((double*) result->pointer));
      break;
    case FFI_TYPE_POINTER:
      value = sv_newmortal();
      if( *((void**)result->pointer) == NULL )
	value = &PL_sv_undef;
      else
	sv_setiv(value, PTR2IV(*((void**)result->pointer)));
      break;
#ifdef FFI_PL_PROBE_LONGDOUBLE
    case FFI_TYPE_LONGDOUBLE:
      value = sv_newmortal();
      ffi_pl_long_double_to_perl(value, (long double*)result->pointer);
      break;
#endif
    default:
      warn("return type not supported");
      return NULL;
    }
    return sv_2mortal(newRV_inc(value));
  }
}

SV *
ffi_pl_rtypes_native_to_perl_record(SV *targ, ffi_pl_result *result, SV *return_type, void *extra_data)
{
  ffi_pl_rtypes_type *pl_return_type = extra_data;
  if(result->pointer != NULL)
  {
    SV *value = sv_newmortal();
    sv_setpvn(value, result->pointer, pl_return_type->extra[0].record.size);
    if(pl_return_type->extra[0].record.stash)
    {
      SV *ref = newRV_inc(value);
      sv_bless(ref, pl_return_type->extra[0].record.stash);
      return ref;
    }
    else
    {
      return value;
    }
  }
  else
  {
    return NULL;
  }
}

SV *
ffi_pl_rtypes_native_to_perl_array(SV *targ, ffi_pl_result *result, SV *return_type, void *extra_data)
{
  ffi_pl_rtypes_type *pl_return_type = extra_data;
  if(result->pointer == NULL)
  {
    return NULL;
  }
  else
  {
    int count = pl_return_type->extra[0].array.element_count;
    AV *av;
    SV **sv;
    int i;
    Newx(sv, count, SV*);
    switch(pl_return_type->ffi_type->type)
    {
    case FFI_TYPE_UINT8:
      for(i=0; i<count; i++)
      {
	sv[i] = newSVuv( ((uint8_t*)result->pointer)[i] );
      }
      break;
    case FFI_TYPE_SINT8:
      for(i=0; i<count; i++)
      {
	sv[i] = newSViv( ((int8_t*)result->pointer)[i] );
      }
      break;
    case FFI_TYPE_UINT16:
      for(i=0; i<count; i++)
      {
	sv[i] = newSVuv( ((uint16_t*)result->pointer)[i] );
      }
      break;
    case FFI_TYPE_SINT16:
      for(i=0; i<count; i++)
      {
	sv[i] = newSViv( ((int16_t*)result->pointer)[i] );
      }
      break;
    case FFI_TYPE_UINT32:
      for(i=0; i<count; i++)
      {
	sv[i] = newSVuv( ((uint32_t*)result->pointer)[i] );
      }
      break;
    case FFI_TYPE_SINT32:
      for(i=0; i<count; i++)
      {
	sv[i] = newSViv( ((int32_t*)result->pointer)[i] );
      }
      break;
    case FFI_TYPE_UINT64:
      for(i=0; i<count; i++)
      {
#ifdef HAVE_IV_IS_64
	sv[i] = newSVuv( ((uint64_t*)result->pointer)[i] );
#else
	sv[i] = newSVu64( ((uint64_t*)result->pointer)[i] );
#endif
      }
      break;
    case FFI_TYPE_SINT64:
      for(i=0; i<count; i++)
      {
#ifdef HAVE_IV_IS_64
	sv[i] = newSViv( ((int64_t*)result->pointer)[i] );
#else
	sv[i] = newSVi64( ((int64_t*)result->pointer)[i] );
#endif
      }
      break;
    case FFI_TYPE_FLOAT:
      for(i=0; i<count; i++)
      {
	sv[i] = newSVnv( ((float*)result->pointer)[i] );
      }
      break;
    case FFI_TYPE_DOUBLE:
      for(i=0; i<count; i++)
      {
	sv[i] = newSVnv( ((double*)result->pointer)[i] );
      }
      break;
    case FFI_TYPE_POINTER:
      for(i=0; i<count; i++)
      {
	if( ((void**)result->pointer)[i] == NULL)
	{
	  sv[i] = &PL_sv_undef;
	}
	else
	{
	  sv[i] = newSViv( PTR2IV( ((void**)result->pointer)[i] ));
	}
      }
      break;
#ifdef FFI_PL_PROBE_LONGDOUBLE
    case FFI_TYPE_LONGDOUBLE:
      for(i=0; i<count; i++)
      {
	sv[i] = newSV(0);
	ffi_pl_long_double_to_perl(sv[i], &((long double*)result->pointer)[i]);
      }
      break;
#endif
    default:
      warn("return type not supported");
      return NULL;
    }
    av = av_make(count, sv);
    Safefree(sv);
    return sv_2mortal(newRV_inc((SV*)av));
  }
}

SV *
ffi_pl_rtypes_native_to_perl_customperl(SV *targ, ffi_pl_result *result, SV *return_type, void *extra_data)
{
  SV *ret_in=NULL, *ret_out;
  AV *av;
  SV **svp;
  STRLEN len;
  const char *name;
  ffi_type *ffi;
  ffi_pl_rtypes_type *pl_return_type = extra_data;

  svp = hv_fetch(pl_return_type->hv, "underlying_types", strlen("underlying_types"), 0);
  av = (AV *)SvRV(*svp);
  svp = av_fetch(av, 0, 0);

  ret_in = SvREFCNT_inc(ffi_pl_rtypes_arguments_native_to_perl(*svp, ffi_pl_rtypes_extra_data(*svp))(targ, result, *svp, ffi_pl_rtypes_extra_data(*svp)));

  {
    HV *hv = (HV*)SvRV(return_type);
    SV **svp;
    SV *arg2 = NULL;
    SV *native_to_perl_sv = NULL;

    svp = hv_fetch(hv, "native_to_perl", strlen("native_to_perl"), 0);
    if (svp) {
      native_to_perl_sv = *svp;
    }
    ret_out = ffi_pl_rtypes_custom_perl(
      native_to_perl_sv,
      ret_in != NULL ? ret_in : &PL_sv_undef,
      -1
      );
  }

  current_argv = NULL;

  SvREFCNT_dec(ret_in);

  if(ret_out == NULL)
  {
    return NULL;
  }
  else
  {
    return sv_2mortal(ret_out);
  }
}

SV *
ffi_pl_rtypes_native_to_perl_exoticfloat(SV *targ, ffi_pl_result *result, SV *return_type, void *extra_data)
{
  ffi_pl_rtypes_type *pl_return_type = extra_data;
  switch(pl_return_type->ffi_type->type)
  {
#ifdef FFI_PL_PROBE_LONGDOUBLE
  case FFI_TYPE_LONGDOUBLE:
    if(have_math_longdouble)
    {
      SV *sv;
      long double *ptr;
      Newx(ptr, 1, long double);
      *ptr = result->longdouble;
      sv = sv_newmortal();
      sv_setref_pv(sv, "Math::LongDouble", (void*)ptr);
      return sv;
    }
    else
    {
      return sv_2mortal(newSVnv((double) result->longdouble));
    }
#endif
  }
}

SV *
ffi_pl_rtypes_sv_native_to_perl(SV *targ, ffi_pl_result *result, SV *return_type, void *extra_data)
{
  return SvREFCNT_inc(result->pointer);
}

native_to_perl_pointer_t
ffi_pl_rtypes_arguments_native_to_perl(SV *type_sv, void *extra_data)
{
  dSP;

  int count;
  void *out_arg;

  ENTER;
  SAVETMPS;
  PUSHMARK(SP);
  XPUSHs(type_sv);
  PUTBACK;

  count = call_method("native_to_perl_pointer", G_SCALAR);

  SPAGAIN;

  if(count == 1)
    out_arg = INT2PTR(void *, SvIVX(POPs));
  else
    out_arg = NULL;

  PUTBACK;
  FREETMPS;
  LEAVE;

  return out_arg;
}

void *
ffi_pl_rtypes_extra_data(SV *type_sv)
{
  dSP;

  int count;
  void *out_arg;

  ENTER;
  SAVETMPS;
  PUSHMARK(SP);
  XPUSHs(type_sv);
  PUTBACK;

  count = call_method("extra_data", G_SCALAR);

  SPAGAIN;

  if(count == 1)
    out_arg = INT2PTR(void *, SvIVX(POPs));
  else
    out_arg = NULL;

  PUTBACK;
  FREETMPS;
  LEAVE;

  return out_arg;
}

/* Local Variables: */
/* c-basic-offset: 2 */
/* c-file-style: "linux" */
/* End: */
