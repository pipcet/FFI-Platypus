#ifndef FFI_PLATYPUS_RTYPES_H
#define FFI_PLATYPUS_RTYPES_H

#include <ffi.h>
#include "ffi_platypus.h"
#include "ffi_platypus_config.h"
#include "ffi_platypus_probe.h"

#ifdef HAVE_DLFCN_H
#ifndef PERL_OS_WINDOWS
#include <dlfcn.h>
#endif
#endif
#ifdef HAVE_UNISTD_H
#include <unistd.h>
#endif
#ifdef HAVE_STDLIB_H
#include <stdlib.h>
#endif
#ifdef HAVE_STDDEF_H
#include <stddef.h>
#endif
#ifdef HAVE_STDINT_H
#include <stdint.h>
#endif
#ifdef HAVE_INTTYPES_H
#include <inttypes.h>
#endif
#ifdef HAVE_ALLOCA_H
#include <alloca.h>
#endif
#ifdef HAVE_STRING_H
#include <string.h>
#endif
#ifdef HAVE_COMPLEX_H
#include <complex.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifndef RTLD_LAZY
#define RTLD_LAZY 0
#endif

#ifdef PERL_OS_WINDOWS

void *windlopen(const char *, int);
const char *windlerror(void);
void *windlsym(void *, const char *);
int windlclose(void *);

#define dlopen(filename, flag) windlopen(filename, flag)
#define dlerror() windlerror()
#define dlsym(handle, symbol) windlsym(handle, symbol)
#define dlclose(handle) windlclose(handle)

#endif

typedef struct _ffi_pl_rtypes_type_extra_record {
  size_t size;
  void *stash; /* really a HV* pointing to the package stash, or NULL */
} ffi_pl_rtypes_type_extra_record;

typedef struct _ffi_pl_rtypes_type_extra_custom_perl {
  size_t size;
} ffi_pl_rtypes_type_extra_custom_perl;

typedef struct _ffi_pl_rtypes_type_extra_array {
  int element_count;
} ffi_pl_rtypes_type_extra_array;

struct _ffi_pl_rtypes_type;

typedef struct _ffi_pl_rtypes_type_extra_string {
  platypus_string_type platypus_string_type;
  size_t size;
} ffi_pl_rtypes_type_extra_string;

typedef union _ffi_pl_rtypes_type_extra {
  ffi_pl_rtypes_type_extra_custom_perl  custom_perl;
  ffi_pl_rtypes_type_extra_array        array;
  ffi_pl_rtypes_type_extra_record       record;
  ffi_pl_rtypes_type_extra_string       string;
} ffi_pl_rtypes_type_extra;

typedef struct _ffi_pl_rtypes_type {
  void *hv; /* the Perl HV* corresponding to our object. Not reference-counted to avoid a circular reference */
  ffi_type *ffi_type;
  ffi_pl_rtypes_type_extra extra[0];
} ffi_pl_rtypes_type;

typedef struct _ffi_pl_rtypes_arguments ffi_pl_rtypes_arguments;
typedef union _ffi_pl_result ffi_pl_result;

typedef int (*perl_to_native_method_t)(ffi_pl_rtypes_arguments *arguments, int i, void *type_sv, void *extra_data, void *arg, void *freeme)  __attribute__((regparm(6)));
typedef void *(*native_to_perl_method_t)(void *targ, ffi_pl_result *result, void *return_type, void *extra_data);

typedef struct _ffi_pl_rtypes_getter {
  void *sv; /* type object */
  void *extra_data;
  int perl_args;
  int native_args;
  int stack_args;
  perl_to_native_method_t perl_to_native;
  perl_to_native_method_t perl_to_native_post;
} ffi_pl_rtypes_getter;

typedef struct _ffi_pl_rtypes_function {
  void *hv; /* The Perl HV* corresponding to our object. Not reference-counted to avoid a circular reference */
  void *address;
  void *impl_sv;  /* really a Perl SV* */
  ffi_cif ffi_cif;
  int nargs_perl;
  int stack_plus_native_args;
  void *return_type;       /* really SV* */
  void *extra_data;

  int any_post;

  native_to_perl_method_t native_to_perl;
  ffi_pl_rtypes_getter argument_getters[0];
} ffi_pl_rtypes_function;

typedef struct _ffi_pl_rtypes_closure {
  ffi_closure *ffi_closure;
  void *function_pointer; /* C function pointer */
  void *coderef;          /* Perl SV* pointing to FFI::Platypus::Closure object */
  void *type;             /* Perl SV* */
} ffi_pl_rtypes_closure;

typedef struct _ffi_pl_rtypes_arguments {
  int count;
  int reserved;
  ffi_pl_argument **pointers;
} ffi_pl_rtypes_arguments;

typedef struct _ffi_pl_rtypes_record_member {
  int offset;
  int count;
} ffi_pl_rtypes_record_member;

#define ffi_pl_rtypes_arguments_count(arguments)                 ((arguments)->count)
#define ffi_pl_rtypes_arguments_set_pointer(arguments, i, value) ((arguments)->pointers[i]->pointer = value)
#define ffi_pl_rtypes_arguments_get_pointer(arguments, i)        ((arguments)->pointers[i]->pointer)
#define ffi_pl_rtypes_arguments_set_string(arguments, i, value)  ((arguments)->pointers[i]->string  = value)
#define ffi_pl_rtypes_arguments_get_string(arguments, i)         ((arguments)->pointers[i]->string)

#define ffi_pl_rtypes_arguments_set_sint8(arguments, i, value)   ((arguments)->pointers[i]->sint8   = value)
#define ffi_pl_rtypes_arguments_get_sint8(arguments, i)          ((arguments)->pointers[i]->sint8)
#define ffi_pl_rtypes_arguments_set_uint8(arguments, i, value)   ((arguments)->pointers[i]->uint8   = value)
#define ffi_pl_rtypes_arguments_get_uint8(arguments, i)          ((arguments)->pointers[i]->uint8)
#define ffi_pl_rtypes_arguments_set_sint16(arguments, i, value)  ((arguments)->pointers[i]->sint16  = value)
#define ffi_pl_rtypes_arguments_get_sint16(arguments, i)         ((arguments)->pointers[i]->sint16)
#define ffi_pl_rtypes_arguments_set_uint16(arguments, i, value)  ((arguments)->pointers[i]->uint16  = value)
#define ffi_pl_rtypes_arguments_get_uint16(arguments, i)         ((arguments)->pointers[i]->uint16)
#define ffi_pl_rtypes_arguments_set_sint32(arguments, i, value)  ((arguments)->pointers[i]->sint32  = value)
#define ffi_pl_rtypes_arguments_get_sint32(arguments, i)         ((arguments)->pointers[i]->sint32)
#define ffi_pl_rtypes_arguments_set_uint32(arguments, i, value)  ((arguments)->pointers[i]->uint32  = value)
#define ffi_pl_rtypes_arguments_get_uint32(arguments, i)         ((arguments)->pointers[i]->uint32)
#define ffi_pl_rtypes_arguments_set_sint64(arguments, i, value)  ((arguments)->pointers[i]->sint64  = value)
#define ffi_pl_rtypes_arguments_get_sint64(arguments, i)         ((arguments)->pointers[i]->sint64)
#define ffi_pl_rtypes_arguments_set_uint64(arguments, i, value)  ((arguments)->pointers[i]->uint64  = value)
#define ffi_pl_rtypes_arguments_get_uint64(arguments, i)         ((arguments)->pointers[i]->uint64)

#define ffi_pl_rtypes_arguments_set_float(arguments, i, value)  ((arguments)->pointers[i]->xfloat  = value)
#define ffi_pl_rtypes_arguments_get_float(arguments, i)         ((arguments)->pointers[i]->xfloat)
#define ffi_pl_rtypes_arguments_set_double(arguments, i, value)  ((arguments)->pointers[i]->xdouble  = value)
#define ffi_pl_rtypes_arguments_get_double(arguments, i)         ((arguments)->pointers[i]->xdouble)

#if defined(_MSC_VER)
#define Newx_or_alloca(ptr, count, type) ptr = _alloca(sizeof(type)*count)
#define Safefree_or_alloca(ptr) 
#define HAVE_ALLOCA 1
#elif defined(HAVE_ALLOCA)
#define Newx_or_alloca(ptr, count, type) ptr = alloca(sizeof(type)*count)
#define Safefree_or_alloca(ptr) 
#else
#define Newx_or_alloca(ptr, count, type) Newx(ptr, count, type)
#define Safefree_or_alloca(ptr) Safefree(ptr)
#endif

ffi_type *ffi_pl_name_to_type(const char *);

#ifdef __cplusplus
}
#endif

extern int have_pm(const char *pm_name);

extern int have_math_longdouble;  /* Math::LongDouble */
extern int have_math_complex;  /* Math::Complex    */

#endif
