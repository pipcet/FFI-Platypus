MODULE = FFI::Platypus PACKAGE = FFI::Platypus::Function::RTypes

ffi_pl_rtypes_function *
new(class, impl, address, abi, return_type_arg, ...)
    const char *class
    SV *impl
    void *address
    int abi
    SV *return_type_arg
  PREINIT:
    ffi_pl_rtypes_function *self;
    int i,n,j;
    SV* arg;
    void *buffer;
    ffi_type *ffi_return_type;
    ffi_type **ffi_argument_types;
    ffi_status ffi_status;
    ffi_pl_rtypes_type *return_type;
    ffi_pl_rtypes_type *tmp;
    ffi_abi ffi_abi;
    int extra_arguments;
    int stack_args;
  CODE:
    ffi_abi = abi == -1 ? FFI_DEFAULT_ABI : abi;
    
    for(i=0,extra_arguments=0; i<(items-5); i++)
    {
      arg = ST(i+5);

      dSP;
      int count;

      if(!(sv_isobject(arg) && sv_derived_from(arg, "FFI::Platypus::Type")))
      {
        croak("non-type parameter passed in as type");
      }

      ENTER;
      SAVETMPS;
      PUSHMARK(SP);
      XPUSHs(arg);
      PUTBACK;

      count = call_method("count_native_arguments", G_SCALAR);

      SPAGAIN;

      if(count == 1)
	extra_arguments += POPi - 1;

      PUTBACK;
      FREETMPS;
      LEAVE;
    }
    SPAGAIN;
  
    Newx(buffer, (sizeof(ffi_pl_rtypes_function) + sizeof(ffi_pl_rtypes_getter)*(items-5)), char);
    self = (ffi_pl_rtypes_function*)buffer;
    Newx(ffi_argument_types, items-5+extra_arguments, ffi_type*);
    
    self->address = address;
    if(self->address == NULL)
    {
      self->address = (items-5+extra_arguments != 0) ? (void *)&cast1 : (void *)&cast0;
    }
    self->return_type = SvREFCNT_inc(return_type_arg);
    self->extra_data = ffi_pl_rtypes_extra_data(return_type_arg);
    self->native_to_perl = (native_to_perl_pointer_t) ffi_pl_rtypes_arguments_native_to_perl(self->return_type, self->extra_data);
    self->any_post = 0;
    SPAGAIN;
    
    if(sv_isobject(self->return_type) && sv_derived_from(self->return_type, "FFI::Platypus::Type::FFI"))
    {
      ffi_return_type = INT2PTR(ffi_type *, SvIV((SV *) SvRV((SV *)self->return_type)));
    }
    else
    {
      if (sv_derived_from(self->return_type, "FFI::Platypus::Type::RTypes::CustomPerl"))
      {
	ffi_pl_rtypes_type *return_type = self->extra_data;
        SV *ret_in=NULL, *ret_out;
	AV *av;
	SV **svp;
	STRLEN len;
	const char *name;
	ffi_type *ffi;

	svp = hv_fetch(return_type->hv, "underlying_types", strlen("underlying_types"), 0);
	av = (AV *)SvRV(*svp);
	svp = av_fetch(av, 0, 0);
	if(sv_derived_from(*svp, "FFI::Platypus::Type::FFI")) {
	  ffi = INT2PTR(ffi_type *, SvIV((SV*)SvRV(*svp)));
	} else if(sv_derived_from(*svp, "FFI::Platypus::Type::Array")) {
	  ffi = &ffi_type_pointer;
	} else {
	  ffi_pl_rtypes_type *svp_type = ffi_pl_rtypes_extra_data(*svp);
	  ffi = svp_type->ffi_type;
	}

        ffi_return_type = ffi;
      }
      else if (sv_derived_from(self->return_type, "FFI::Platypus::Type::RTypes::ExoticFloat"))
      {
	ffi_pl_rtypes_type *return_type = self->extra_data;

	ffi_return_type = return_type->ffi_type;
      }
      else
      {
        ffi_return_type = &ffi_type_pointer;
      }
    }

    for(i=0,n=0; i<(items-5); i++,n++)
    {
      arg = ST(i+5);
      self->argument_getters[i].sv = SvREFCNT_inc(arg);
      self->argument_getters[i].perl_args = 1;
      self->argument_getters[i].native_args = 1;
      self->argument_getters[i].stack_args = 0;
      
      self->argument_getters[i].extra_data = ffi_pl_rtypes_extra_data(arg);
      self->argument_getters[i].perl_to_native = (perl_to_native_pointer_t) ffi_pl_rtypes_arguments_perl_to_native(arg, ffi_pl_rtypes_extra_data(arg));
      self->argument_getters[i].perl_to_native_post = (perl_to_native_pointer_t) ffi_pl_rtypes_arguments_perl_to_native_post(arg, ffi_pl_rtypes_extra_data(arg));
      self->any_post |= (self->argument_getters[i].perl_to_native_post != NULL);

      if(sv_isobject(arg) && sv_derived_from(arg, "FFI::Platypus::Type::FFI"))
      {
        ffi_argument_types[n] = INT2PTR(ffi_type *, SvIV((SV *) SvRV((SV *)arg)));
      }
      else
      {
	if(sv_derived_from(arg, "FFI::Platypus::Type::RTypes::CustomPerl"))
        {
	  int d = ffi_pl_rtypes_prepare_customperl(self->argument_getters+i, self->argument_getters+(items-5), ffi_argument_types+n, ffi_argument_types+(items-5+extra_arguments), arg, ffi_pl_rtypes_extra_data(arg)) - 1;
	  if(d < 0) {
	    Safefree(self);
	    Safefree(ffi_argument_types);
	    croak("prepare_customperl failed");
	  }
	    
	  n += d;
        }
	else if (sv_derived_from(arg, "FFI::Platypus::Type::RTypes::Wrap"))
	{
	  int d = ffi_pl_rtypes_prepare_any(self->argument_getters+i, self->argument_getters+(items-5), ffi_argument_types+n, ffi_argument_types+(items-5+extra_arguments), arg, ffi_pl_rtypes_extra_data(arg)) - 1;
	  if(d < 0) {
	    Safefree(self);
	    Safefree(ffi_argument_types);
	    croak("prepare_any failed");
	  }

	  n += d;
	}
	else if (sv_derived_from(arg, "FFI::Platypus::Type::RTypes::ExoticFloat"))
        {
	  tmp = ffi_pl_rtypes_extra_data(arg);
          ffi_argument_types[n] = tmp->ffi_type;
        }
        else
        {
          ffi_argument_types[n] = &ffi_type_pointer;
        }
      }
      SPAGAIN;
    }

    if(n < items-5+extra_arguments)
    {
      int stack_args = 0;
      for(i=0; i<(items-5); i++)
      {
	arg = ST(i+5);

	dSP;
	int count;
	
	if(!(sv_isobject(arg) && sv_derived_from(arg, "FFI::Platypus::Type")))
	{
	  croak("non-type parameter passed in as type");
	}
	
	ENTER;
	SAVETMPS;
	PUSHMARK(SP);
	XPUSHs(arg);
	PUTBACK;
	
	count = call_method("count_native_arguments", G_SCALAR);

	SPAGAIN;

	if(count == 1)
	{
	  int local_stack_args = POPi - self->argument_getters[i].native_args;

	  self->argument_getters[i].stack_args = local_stack_args;
	  stack_args += local_stack_args;
	}

	PUTBACK;
	FREETMPS;
	LEAVE;
      }
      self->stack_args = stack_args;
    } else {
      self->stack_args = 0;
    }
    SPAGAIN;


    self->nargs_perl = i;
    
    ffi_status = ffi_prep_cif(
      &self->ffi_cif,            /* ffi_cif     | */
      ffi_abi,                   /* ffi_abi     | */
      n,                         /* int         | argument count */
      ffi_return_type,           /* ffi_type *  | return type */
      ffi_argument_types         /* ffi_type ** | argument types */
    );
    
    if(ffi_status != FFI_OK)
    {
      Safefree(self);
      Safefree(ffi_argument_types);
      if(ffi_status == FFI_BAD_TYPEDEF)
        croak("bad typedef");
      else if(ffi_status == FFI_BAD_ABI)
        croak("bad abi");
      else
        croak("unknown error with ffi_prep_cif");
    }
    
    self->impl_sv = SvREFCNT_inc(impl);

    RETVAL = self;
  OUTPUT:
    RETVAL

void
call(self, ...)
    ffi_pl_rtypes_function *self
  PREINIT:
    int i, n, perl_arg_index, perl_type_index;
    SV *arg;
    ffi_pl_result result;
    ffi_pl_rtypes_arguments arguments;
    SV *freeme = NULL; /* scratch space for custom perl handlers */
#ifndef FFI_PL_PROBE_RUNTIMESIZEDARRAYS
    void **argument_pointers;
    ffi_pl_argument *argument_slots;
#endif
  CODE:
#define EXTRA_ARGS 1
#include "ffi_platypus_rtypes_call.h"


void
ffi_pl_method_implementation(self)
    SV *self
  PPCODE:
    XPUSHs(sv_2mortal(SvREFCNT_inc(self)));
    XPUSHs(sv_2mortal(newSViv(PTR2IV(ffi_pl_rtypes_method_call_body))));
    PUTBACK;
    XSRETURN(2);

void
attach_method(self, ffi, object, object_key, first_argument, drop_first_argument, perl_name, path_name, proto)
    SV *self
    SV *ffi
    SV *object
    SV *object_key
    SV *first_argument
    int drop_first_argument
    const char *perl_name
    ffi_pl_string path_name
    ffi_pl_string proto
  PREINIT:
    CV *cv;
    ffi_pl_cached_method *method;
    SV *value;
    int count;
    SV *sv;
  CODE:
    if(!(sv_isobject(self) && sv_derived_from(self, "FFI::Platypus::Function::RTypes")))
      croak("self is not of type FFI::Platypus::Function::RTypes");

    if(path_name == NULL)
      path_name = "unknown";

    cv = get_cv(perl_name, 0);

    if(cv == NULL
    || CvXSUB(cv) != ffi_pl_method_call)
    {
      Newx(method, 1, ffi_pl_cached_method);
      method->body = NULL;
      method->function = NULL;
      method->weakref = NULL; /* create on first call */
      method->argument = NULL;
      method->other_methods = newHV();

      if(proto == NULL)
	cv = newXS(perl_name, ffi_pl_method_call, path_name);
      else
      {
	/*
	 * this ifdef is needed for Perl 5.8.8 support.
	 * once we don't need to support 5.8.8 we can
	 * remove this workaround (the ndef'd branch)
	 */
#ifdef newXS_flags
	cv = newXSproto(perl_name, ffi_pl_method_call, path_name, proto);
#else
	newXSproto(perl_name, ffi_pl_method_call, path_name, proto);
	cv = get_cv(perl_name,0);
#endif
      }
      CvXSUBANY(cv).any_ptr = (void *) method;
      /*
       * No coresponding decrement !!
       * once attached, you can never free the function object, or the FFI::Platypus
       * it was created from.
       */
      SvREFCNT_inc(self);
    }
    else
    {
      /*
       * Ideally, we should check here that the prototype of the
       * existing CV matches the one we request. However, I don't know
       * how to do that.
       */
      method = CvXSUBANY(cv).any_ptr;
    }

    value = newRV_noinc((SV*)newHV());
    hv_store((HV*)SvRV(value), "ffi", strlen("ffi"), SvREFCNT_inc(ffi), 0);

    PUSHMARK(SP);
    XPUSHs(self);
    PUTBACK;
    count = call_method("ffi_pl_method_implementation", G_ARRAY);
    SPAGAIN;

    if(count != 2)
      croak("ffi_pl_method_implementation failed");

    sv = POPs;
    hv_store((HV*)SvRV(value), "body", strlen("body"), SvREFCNT_inc(sv), 0);
    sv = POPs;
    hv_store((HV*)SvRV(value), "function", strlen("function"), SvREFCNT_inc(sv), 0);

    if(SvROK(object))
    {
      hv_store((HV*)SvRV(value), "weakref", strlen("weakref"), sv_rvweaken(newSVsv(object)), 0);
    }
    if(!drop_first_argument)
    {
      hv_store((HV*)SvRV(value), "argument", strlen("argument"), SvREFCNT_inc(first_argument), 0);
    }

    hv_store_ent(method->other_methods, object_key, value, 0);

    /* we might have replaced a previous attachment to the same
       object. This could be optimized. */
    method->weakref = NULL;

void
attach(self, perl_name, path_name, proto)
    SV *self
    const char *perl_name
    ffi_pl_string path_name
    ffi_pl_string proto
  PREINIT:
    CV* cv;
  CODE:
    if(!(sv_isobject(self) && sv_derived_from(self, "FFI::Platypus::Function::RTypes")))
      croak("self is not of type FFI::Platypus::Function::RTypes");

    if(path_name == NULL)
      path_name = "unknown";

    if(proto == NULL)
      cv = newXS(perl_name, ffi_pl_rtypes_sub_call, path_name);
    else
    {
      /*
       * this ifdef is needed for Perl 5.8.8 support.
       * once we don't need to support 5.8.8 we can
       * remove this workaround (the ndef'd branch)
       */
#ifdef newXS_flags
      cv = newXSproto(perl_name, ffi_pl_rtypes_sub_call, path_name, proto);
#else
      newXSproto(perl_name, ffi_pl_rtypes_sub_call, path_name, proto);
      cv = get_cv(perl_name,0);
#endif
    }
    CvXSUBANY(cv).any_ptr = (void *) INT2PTR(ffi_pl_rtypes_function*, SvIV((SV*) SvRV(self)));
    /*
     * No coresponding decrement !!
     * once attached, you can never free the function object, or the FFI::Platypus
     * it was created from.
     */
    SvREFCNT_inc(self);

void
DESTROY(self)
    ffi_pl_rtypes_function *self
  PREINIT:
    int i;
  CODE:
    SvREFCNT_dec(self->impl_sv);
    SvREFCNT_dec(self->return_type);
    for (i=0; i<self->nargs_perl; i++) {
      SvREFCNT_dec(self->argument_getters[i].sv);
    }
    Safefree(self->ffi_cif.arg_types);
    Safefree(self);

