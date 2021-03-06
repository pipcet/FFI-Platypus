#ifndef FFI_PLATYPUS_RTYPES_GUTS_H
#define FFI_PLATYPUS_RTYPES_GUTS_H
#ifdef __cplusplus
extern "C" {
#endif

void ffi_pl_rtypes_closure_call(ffi_cif *, void *, void **, void *);
SV *ffi_pl_rtypes_closure_add_data(SV *closure, SV *type, void *closure_data);
ffi_pl_rtypes_closure *ffi_pl_rtypes_closure_get_data(SV *closure, SV *type);
SV*  ffi_pl_rtypes_custom_perl(SV*,SV*,int);
SV*  ffi_pl_rtypes_custom_array_perl(SV*,SV*,int);
void ffi_pl_rtypes_custom_perl_cb(SV *, SV*, int);
HV *ffi_pl_rtypes_ffi_get_type_meta(ffi_type *);
HV *ffi_pl_rtypes_get_type_meta(SV *);
HV *ffi_pl_ffi_get_type_meta(ffi_type *); /* XXX no rtypes prefix */
size_t ffi_pl_rtypes_sizeof(SV *,ffi_pl_rtypes_type *);
void ffi_pl_rtypes_perl_complex_float(SV *sv, float *ptr);
void ffi_pl_rtypes_perl_complex_double(SV *sv, double *ptr);

void ffi_pl_rtypes_method_call_body(pTHX_ void *self_ptr, int extra_args);

int ffi_pl_rtypes_perl_to_native_any(ffi_pl_rtypes_arguments *arguments, int i, SV *type_sv, void *extra_data, SV *arg, SV **freeme) __attribute__((regparm(6)));
int ffi_pl_rtypes_perl_to_native_any_post(ffi_pl_rtypes_arguments *arguments, int i, SV *type_sv, void *extra_data, SV *arg, SV **freeme) __attribute__((regparm(6)));
SV *ffi_pl_rtypes_any_native_to_perl(SV *, ffi_pl_result *, SV *, void *);

void *ffi_pl_rtypes_extra_data(SV *);
perl_to_native_method_t ffi_pl_rtypes_perl_to_native_method(SV *, void *);
perl_to_native_method_t ffi_pl_rtypes_perl_to_native_post_method(SV *, void *);
native_to_perl_method_t ffi_pl_rtypes_native_to_perl_method(SV *, void *);

#define ffi_pl_perl_to_long_double(sv, ptr)                           \
  if(!SvOK(sv))                                                       \
  {                                                                   \
    *(ptr) = 0.0L;                                                    \
  }                                                                   \
  else if(sv_isobject(sv) && sv_derived_from(sv, "Math::LongDouble")) \
  {                                                                   \
    *(ptr) = *INT2PTR(long double *, SvIV((SV*) SvRV(sv)));           \
  }                                                                   \
  else                                                                \
  {                                                                   \
    *(ptr) = (long double) SvNV(sv);                                  \
  }

/*
 * CAVEATS:
 *  - We are mucking about with the innerds of Math::LongDouble
 *    so if the innerds change we may break Math::LongDouble,
 *    FFI::Platypus or both!
 *  - This makes Math::LongDouble mutable.  Note however, that
 *    Math::LongDouble overloads ++ and increments the actual
 *    longdouble pointed to in memory, so we are at least not
 *    introducing the sin of mutability.  See LongDouble.xs
 *    C function _overload_inc.
 */

#define ffi_pl_long_double_to_perl(sv, ptr)                      \
  if(sv_isobject(sv) && sv_derived_from(sv, "Math::LongDouble")) \
  {                                                              \
    *INT2PTR(long double *, SvIV((SV*) SvRV(sv))) = *(ptr);      \
  }                                                              \
  else if(have_math_longdouble)                                  \
  {                                                              \
    long double *tmp;                                            \
    Newx(tmp, 1, long double);                                   \
    *tmp = *(ptr);                                               \
    sv_setref_pv(sv, "Math::LongDouble", (void*)tmp);            \
  }                                                              \
  else                                                           \
  {                                                              \
    sv_setnv(sv, *(ptr));                                        \
  }

int ffi_pl_rtypes_perl_to_native_ffi_void(ffi_pl_rtypes_arguments *arguments, int i, SV *arg_type, void *extra_data, SV *arg, SV **freeme) __attribute__((regparm(3))) __attribute((regparm(6)));
int ffi_pl_rtypes_perl_to_native_ffi_uint8(ffi_pl_rtypes_arguments *arguments, int i, SV *arg_type, void *extra_data, SV *arg, SV **freeme) __attribute__((regparm(3))) __attribute((regparm(6)));
int ffi_pl_rtypes_perl_to_native_ffi_sint8(ffi_pl_rtypes_arguments *arguments, int i, SV *arg_type, void *extra_data, SV *arg, SV **freeme) __attribute__((regparm(3))) __attribute((regparm(6)));
int ffi_pl_rtypes_perl_to_native_ffi_uint16(ffi_pl_rtypes_arguments *arguments, int i, SV *arg_type, void *extra_data, SV *arg, SV **freeme) __attribute__((regparm(3))) __attribute((regparm(6)));
int ffi_pl_rtypes_perl_to_native_ffi_sint16(ffi_pl_rtypes_arguments *arguments, int i, SV *arg_type, void *extra_data, SV *arg, SV **freeme) __attribute__((regparm(3))) __attribute((regparm(6)));
int ffi_pl_rtypes_perl_to_native_ffi_uint32(ffi_pl_rtypes_arguments *arguments, int i, SV *arg_type, void *extra_data, SV *arg, SV **freeme) __attribute__((regparm(3))) __attribute((regparm(6)));
int ffi_pl_rtypes_perl_to_native_ffi_sint32(ffi_pl_rtypes_arguments *arguments, int i, SV *arg_type, void *extra_data, SV *arg, SV **freeme) __attribute__((regparm(3))) __attribute((regparm(6)));
int ffi_pl_rtypes_perl_to_native_ffi_uint64(ffi_pl_rtypes_arguments *arguments, int i, SV *arg_type, void *extra_data, SV *arg, SV **freeme) __attribute__((regparm(3))) __attribute((regparm(6)));
int ffi_pl_rtypes_perl_to_native_ffi_sint64(ffi_pl_rtypes_arguments *arguments, int i, SV *arg_type, void *extra_data, SV *arg, SV **freeme) __attribute__((regparm(3))) __attribute((regparm(6)));
int ffi_pl_rtypes_perl_to_native_ffi_float(ffi_pl_rtypes_arguments *arguments, int i, SV *arg_type, void *extra_data, SV *arg, SV **freeme) __attribute__((regparm(3))) __attribute((regparm(6)));
int ffi_pl_rtypes_perl_to_native_ffi_double(ffi_pl_rtypes_arguments *arguments, int i, SV *arg_type, void *extra_data, SV *arg, SV **freeme) __attribute__((regparm(3))) __attribute((regparm(6)));
int ffi_pl_rtypes_perl_to_native_ffi_pointer(ffi_pl_rtypes_arguments *arguments, int i, SV *arg_type, void *extra_data, SV *arg, SV **freeme) __attribute__((regparm(3))) __attribute((regparm(6)));

int ffi_pl_rtypes_perl_to_native_any(ffi_pl_rtypes_arguments *arguments, int i, SV *type_sv, void *extra_data, SV *arg, SV **freeme) __attribute__((regparm(3))) __attribute((regparm(6)));
int ffi_pl_rtypes_perl_to_native_array(ffi_pl_rtypes_arguments *arguments, int i, SV *type_sv, void *extra_data, SV *arg, SV **freeme) __attribute__((regparm(3))) __attribute((regparm(6)));
int ffi_pl_rtypes_perl_to_native_closure(ffi_pl_rtypes_arguments *arguments, int i, SV *type_sv, void *extra_data, SV *arg, SV **freeme) __attribute__((regparm(3))) __attribute((regparm(6)));
int ffi_pl_rtypes_perl_to_native_constant(ffi_pl_rtypes_arguments *arguments, int i, SV *type_sv, void *extra_data, SV *arg, SV **freeme) __attribute__((regparm(3))) __attribute((regparm(6)));
int ffi_pl_rtypes_perl_to_native_customperl(ffi_pl_rtypes_arguments *arguments, int i, SV *type_sv, void *extra_data, SV *arg, SV **freeme) __attribute__((regparm(3))) __attribute((regparm(6)));
int ffi_pl_rtypes_perl_to_native_exoticfloat(ffi_pl_rtypes_arguments *arguments, int i, SV *type_sv, void *extra_data, SV *arg, SV **freeme) __attribute__((regparm(3))) __attribute((regparm(6)));
int ffi_pl_rtypes_perl_to_native_perl_string(ffi_pl_rtypes_arguments *arguments, int i, SV *type_sv, void *extra_data, SV *arg, SV **freeme) __attribute__((regparm(3))) __attribute((regparm(6)));
int ffi_pl_rtypes_perl_to_native_perl_string_variable(ffi_pl_rtypes_arguments *arguments, int i, SV *type_sv, void *extra_data, SV *arg, SV **freeme) __attribute__((regparm(3))) __attribute((regparm(6)));
int ffi_pl_rtypes_perl_to_native_record(ffi_pl_rtypes_arguments *arguments, int i, SV *type_sv, void *extra_data, SV *arg, SV **freeme) __attribute__((regparm(3))) __attribute((regparm(6)));
int ffi_pl_rtypes_perl_to_native_pointer(ffi_pl_rtypes_arguments *arguments, int i, SV *type_sv, void *extra_data, SV *arg, SV **freeme) __attribute__((regparm(3))) __attribute((regparm(6)));
int ffi_pl_rtypes_perl_to_native_pointer_sint32(ffi_pl_rtypes_arguments *arguments, int i, SV *type_sv, void *extra_data, SV *arg, SV **freeme) __attribute__((regparm(3))) __attribute((regparm(6)));
int ffi_pl_rtypes_sv_perl_to_native(ffi_pl_rtypes_arguments *arguments, int i, SV *type_sv, void *extra_data, SV *arg, SV **freeme) __attribute__((regparm(3))) __attribute((regparm(6)));

int ffi_pl_rtypes_perl_to_native_any_post(ffi_pl_rtypes_arguments *arguments, int i, SV *type_sv, void *extra_data, SV *arg, SV **freeme) __attribute__((regparm(3))) __attribute((regparm(6)));
int ffi_pl_rtypes_perl_to_native_array_post(ffi_pl_rtypes_arguments *arguments, int i, SV *type_sv, void *extra_data, SV *arg, SV **freeme) __attribute__((regparm(3))) __attribute((regparm(6)));
int ffi_pl_rtypes_perl_to_native_closure_post(ffi_pl_rtypes_arguments *arguments, int i, SV *type_sv, void *extra_data, SV *arg, SV **freeme) __attribute__((regparm(3))) __attribute((regparm(6)));
int ffi_pl_rtypes_perl_to_native_custom_perl_post(ffi_pl_rtypes_arguments *arguments, int i, SV *type_sv, void *extra_data, SV *arg, SV **freeme) __attribute__((regparm(3))) __attribute((regparm(6)));
int ffi_pl_rtypes_perl_to_native_exoticfloat_post(ffi_pl_rtypes_arguments *arguments, int i, SV *type_sv, void *extra_data, SV *arg, SV **freeme) __attribute__((regparm(3))) __attribute((regparm(6)));
int ffi_pl_rtypes_perl_to_native_pointer_post(ffi_pl_rtypes_arguments *arguments, int i, SV *type_sv, void *extra_data, SV *arg, SV **freeme) __attribute__((regparm(3))) __attribute((regparm(6)));
int ffi_pl_rtypes_perl_to_native_pointer_post_sint32(ffi_pl_rtypes_arguments *arguments, int i, SV *type_sv, void *extra_data, SV *arg, SV **freeme) __attribute__((regparm(3))) __attribute((regparm(6)));
int ffi_pl_rtypes_sv_perl_to_native_post(ffi_pl_rtypes_arguments *arguments, int i, SV *type_sv, void *extra_data, SV *arg, SV **freeme) __attribute__((regparm(3))) __attribute((regparm(6)));

SV *ffi_pl_rtypes_native_to_perl_void(SV *targ, ffi_pl_result *result, SV *return_type, void *extra_data);

SV *ffi_pl_rtypes_native_to_perl_ffi_uint8(SV *targ, ffi_pl_result *result, SV *return_type, void *extra_data);
SV *ffi_pl_rtypes_native_to_perl_ffi_sint8(SV *targ, ffi_pl_result *result, SV *return_type, void *extra_data);
SV *ffi_pl_rtypes_native_to_perl_ffi_uint16(SV *targ, ffi_pl_result *result, SV *return_type, void *extra_data);
SV *ffi_pl_rtypes_native_to_perl_ffi_sint16(SV *targ, ffi_pl_result *result, SV *return_type, void *extra_data);
SV *ffi_pl_rtypes_native_to_perl_ffi_uint32(SV *targ, ffi_pl_result *result, SV *return_type, void *extra_data);
SV *ffi_pl_rtypes_native_to_perl_ffi_sint32(SV *targ, ffi_pl_result *result, SV *return_type, void *extra_data);
SV *ffi_pl_rtypes_native_to_perl_ffi_uint64(SV *targ, ffi_pl_result *result, SV *return_type, void *extra_data);
SV *ffi_pl_rtypes_native_to_perl_ffi_sint64(SV *targ, ffi_pl_result *result, SV *return_type, void *extra_data);
SV *ffi_pl_rtypes_native_to_perl_ffi_float(SV *targ, ffi_pl_result *result, SV *return_type, void *extra_data);
SV *ffi_pl_rtypes_native_to_perl_ffi_double(SV *targ, ffi_pl_result *result, SV *return_type, void *extra_data);
SV *ffi_pl_rtypes_native_to_perl_ffi_pointer(SV *targ, ffi_pl_result *result, SV *return_type, void *extra_data);

SV *ffi_pl_rtypes_native_to_perl_string_variable(SV *targ, ffi_pl_result *result, SV *return_type, void *extra_data);
SV *ffi_pl_rtypes_native_to_perl_string(SV *targ, ffi_pl_result *result, SV *return_type, void *extra_data);
SV *ffi_pl_rtypes_native_to_perl_pointer(SV *targ, ffi_pl_result *result, SV *return_type, void *extra_data);
SV *ffi_pl_rtypes_native_to_perl_record(SV *targ, ffi_pl_result *result, SV *return_type, void *extra_data);
SV *ffi_pl_rtypes_native_to_perl_array(SV *targ, ffi_pl_result *result, SV *return_type, void *extra_data);
SV *ffi_pl_rtypes_native_to_perl_customperl(SV *targ, ffi_pl_result *result, SV *return_type, void *extra_data);
SV *ffi_pl_rtypes_native_to_perl_exoticfloat(SV *targ, ffi_pl_result *result, SV *return_type, void *extra_data);
SV *ffi_pl_rtypes_sv_native_to_perl(SV *targ, ffi_pl_result *result, SV *return_type, void *extra_data);
int ffi_pl_rtypes_prepare_ffi(ffi_pl_rtypes_getter *getters, ffi_pl_rtypes_getter *getters_limit, ffi_type **ffi_argument_types, ffi_type **ffi_argument_types_limit, SV *arg_type, void *extra_data);
int ffi_pl_rtypes_prepare_array(ffi_pl_rtypes_getter *getters, ffi_pl_rtypes_getter *getters_limit, ffi_type **ffi_argument_types, ffi_type **ffi_argument_types_limit, SV *arg_type, void *extra_data);
int ffi_pl_rtypes_prepare_customperl(ffi_pl_rtypes_getter *getters, ffi_pl_rtypes_getter *getters_limit, ffi_type **ffi_argument_types, ffi_type **ffi_argument_types_limit, SV *arg_type, void *extra_data);
int ffi_pl_rtypes_prepare_generic(ffi_pl_rtypes_getter *getters, ffi_pl_rtypes_getter *getters_limit, ffi_type **ffi_argument_types, ffi_type **ffi_argument_types_limit, SV *arg_type, void *extra_data);
int ffi_pl_rtypes_prepare_sv(ffi_pl_rtypes_getter *getters, ffi_pl_rtypes_getter *getters_limit, ffi_type **ffi_argument_types, ffi_type **ffi_argument_types_limit, SV *arg_type, void *extra_data);
int ffi_pl_rtypes_prepare_closure(ffi_pl_rtypes_getter *getters, ffi_pl_rtypes_getter *getters_limit, ffi_type **ffi_argument_types, ffi_type **ffi_argument_types_limit, SV *arg_type, void *extra_data);

int ffi_pl_rtypes_prepare_any(ffi_pl_rtypes_getter *getters, ffi_pl_rtypes_getter *getters_limit, ffi_type **ffi_argument_types, ffi_type **ffi_argument_types_limit, SV *arg_type, void *extra_data);

#ifdef __cplusplus
}
#endif
#endif
