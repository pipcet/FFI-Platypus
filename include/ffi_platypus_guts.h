#ifndef FFI_PLATYPUS_GUTS_H
#define FFI_PLATYPUS_GUTS_H
#ifdef __cplusplus
extern "C" {
#endif

void ffi_pl_closure_call(ffi_cif *, void *, void **, void *);
SV *ffi_pl_closure_add_data(SV *closure, ffi_pl_closure *closure_data);
ffi_pl_closure *ffi_pl_closure_get_data(SV *closure, SV *type);
SV*  ffi_pl_custom_perl(SV*,SV*,int);
SV*  ffi_pl_custom_array_perl(SV*,SV*,int);
void ffi_pl_custom_perl_cb(SV *, SV*, int);
HV *ffi_pl_ffi_get_type_meta(ffi_type *);
HV *ffi_pl_get_type_meta(SV *);
size_t ffi_pl_sizeof(SV *,ffi_pl_type *);
void ffi_pl_perl_complex_float(SV *sv, float *ptr);
void ffi_pl_perl_complex_double(SV *sv, double *ptr);

int ffi_pl_arguments_set_any(ffi_pl_arguments *arguments, int i, SV *type_sv, SV *arg, SV **freeme);
int ffi_pl_arguments_set_any_post(ffi_pl_arguments *arguments, int i, SV *type_sv, SV *arg, SV **freeme);
SV *ffi_pl_any_native_to_perl(ffi_pl_result *, SV *);

int (*ffi_pl_arguments_perl_to_native(SV *type_sv))(ffi_pl_arguments *arguments, int i, SV *type_sv, SV *arg, SV **freeme);
int (*ffi_pl_arguments_perl_to_native_post(SV *type_sv))(ffi_pl_arguments *arguments, int i, SV *type_sv, SV *arg, SV **freeme);
SV *(*ffi_pl_arguments_native_to_perl(SV *type_sv))(ffi_pl_result *result, SV *return_type);


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

extern ffi_pl_arguments *current_argv;

int ffi_pl_arguments_set_ffi_void(ffi_pl_arguments *arguments, int i, SV *arg_type, SV *arg, SV **freeme);
int ffi_pl_arguments_set_ffi_uint8(ffi_pl_arguments *arguments, int i, SV *arg_type, SV *arg, SV **freeme);
int ffi_pl_arguments_set_ffi_sint8(ffi_pl_arguments *arguments, int i, SV *arg_type, SV *arg, SV **freeme);
int ffi_pl_arguments_set_ffi_uint16(ffi_pl_arguments *arguments, int i, SV *arg_type, SV *arg, SV **freeme);
int ffi_pl_arguments_set_ffi_sint16(ffi_pl_arguments *arguments, int i, SV *arg_type, SV *arg, SV **freeme);
int ffi_pl_arguments_set_ffi_uint32(ffi_pl_arguments *arguments, int i, SV *arg_type, SV *arg, SV **freeme);
int ffi_pl_arguments_set_ffi_sint32(ffi_pl_arguments *arguments, int i, SV *arg_type, SV *arg, SV **freeme);
int ffi_pl_arguments_set_ffi_uint64(ffi_pl_arguments *arguments, int i, SV *arg_type, SV *arg, SV **freeme);
int ffi_pl_arguments_set_ffi_sint64(ffi_pl_arguments *arguments, int i, SV *arg_type, SV *arg, SV **freeme);
int ffi_pl_arguments_set_ffi_float(ffi_pl_arguments *arguments, int i, SV *arg_type, SV *arg, SV **freeme);
int ffi_pl_arguments_set_ffi_double(ffi_pl_arguments *arguments, int i, SV *arg_type, SV *arg, SV **freeme);
int ffi_pl_arguments_set_ffi_pointer(ffi_pl_arguments *arguments, int i, SV *arg_type, SV *arg, SV **freeme);

int ffi_pl_arguments_set_any(ffi_pl_arguments *arguments, int i, SV *type_sv, SV *arg, SV **freeme);
int ffi_pl_arguments_set_array(ffi_pl_arguments *arguments, int i, SV *type_sv, SV *arg, SV **freeme);
int ffi_pl_arguments_set_closure(ffi_pl_arguments *arguments, int i, SV *type_sv, SV *arg, SV **freeme);
int ffi_pl_arguments_set_constant(ffi_pl_arguments *arguments, int i, SV *type_sv, SV *arg, SV **freeme);
int ffi_pl_arguments_set_customperl(ffi_pl_arguments *arguments, int i, SV *type_sv, SV *arg, SV **freeme);
int ffi_pl_arguments_set_exoticfloat(ffi_pl_arguments *arguments, int i, SV *type_sv, SV *arg, SV **freeme);
int ffi_pl_arguments_set_perl_string(ffi_pl_arguments *arguments, int i, SV *type_sv, SV *arg, SV **freeme);
int ffi_pl_arguments_set_record(ffi_pl_arguments *arguments, int i, SV *type_sv, SV *arg, SV **freeme);
int ffi_pl_arguments_set_ref(ffi_pl_arguments *arguments, int i, SV *type_sv, SV *arg, SV **freeme);

int ffi_pl_arguments_set_any_post(ffi_pl_arguments *arguments, int i, SV *type_sv, SV *arg, SV **freeme);
int ffi_pl_arguments_set_array_post(ffi_pl_arguments *arguments, int i, SV *type_sv, SV *arg, SV **freeme);
int ffi_pl_arguments_set_closure_post(ffi_pl_arguments *arguments, int i, SV *type_sv, SV *arg, SV **freeme);
int ffi_pl_arguments_set_custom_perl_post(ffi_pl_arguments *arguments, int i, SV *type_sv, SV *arg, SV **freeme);
int ffi_pl_arguments_set_exoticfloat_post(ffi_pl_arguments *arguments, int i, SV *type_sv, SV *arg, SV **freeme);
int ffi_pl_arguments_set_ref_post(ffi_pl_arguments *arguments, int i, SV *type_sv, SV *arg, SV **freeme);

SV *ffi_pl_native_to_perl_void(ffi_pl_result *result, SV *return_type);

SV *ffi_pl_native_to_perl_ffi_uint8(ffi_pl_result *result, SV *return_type);
SV *ffi_pl_native_to_perl_ffi_sint8(ffi_pl_result *result, SV *return_type);
SV *ffi_pl_native_to_perl_ffi_uint16(ffi_pl_result *result, SV *return_type);
SV *ffi_pl_native_to_perl_ffi_sint16(ffi_pl_result *result, SV *return_type);
SV *ffi_pl_native_to_perl_ffi_uint32(ffi_pl_result *result, SV *return_type);
SV *ffi_pl_native_to_perl_ffi_sint32(ffi_pl_result *result, SV *return_type);
SV *ffi_pl_native_to_perl_ffi_uint64(ffi_pl_result *result, SV *return_type);
SV *ffi_pl_native_to_perl_ffi_sint64(ffi_pl_result *result, SV *return_type);
SV *ffi_pl_native_to_perl_ffi_float(ffi_pl_result *result, SV *return_type);
SV *ffi_pl_native_to_perl_ffi_double(ffi_pl_result *result, SV *return_type);
SV *ffi_pl_native_to_perl_ffi_pointer(ffi_pl_result *result, SV *return_type);

SV *ffi_pl_native_to_perl_string(ffi_pl_result *result, SV *return_type);
SV *ffi_pl_native_to_perl_pointer(ffi_pl_result *result, SV *return_type);
SV *ffi_pl_native_to_perl_record(ffi_pl_result *result, SV *return_type);
SV *ffi_pl_native_to_perl_array(ffi_pl_result *result, SV *return_type);
SV *ffi_pl_native_to_perl_customperl(ffi_pl_result *result, SV *return_type);
SV *ffi_pl_native_to_perl_exoticfloat(ffi_pl_result *result, SV *return_type);

int ffi_pl_prepare_ffi(ffi_pl_getter *getters, int i, ffi_type **ffi_argument_types, int n, SV *arg_type);
int ffi_pl_prepare_array(ffi_pl_getter *getters, int i, ffi_type **ffi_argument_types, int n, SV *arg_type);
int ffi_pl_prepare_customperl(ffi_pl_getter *getters, int i, ffi_type **ffi_argument_types, int n, SV *arg_type);
int ffi_pl_prepare_generic(ffi_pl_getter *getters, int i, ffi_type **ffi_argument_types, int n, SV *arg_type);

int ffi_pl_prepare_any(ffi_pl_getter *getters, int i, ffi_type **ffi_argument_types, int n, SV *arg_type);

#ifdef __cplusplus
}
#endif
#endif
