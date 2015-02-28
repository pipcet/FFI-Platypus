MODULE = FFI::Platypus PACKAGE = FFI::Platypus::Function

ffi_pl_function *
new(class, platypus, address, abi, return_type_arg, ...)
    const char *class
    SV *platypus
    void *address
    int abi
    SV *return_type_arg
  PREINIT:
    ffi_pl_function *self;
    int i,n,j;
    SV* arg;
    void *buffer;
    ffi_type *ffi_return_type;
    ffi_type **ffi_argument_types;
    ffi_status ffi_status;
    ffi_pl_type *return_type;
    ffi_pl_type *tmp;
    ffi_abi ffi_abi;
    int extra_arguments;
  CODE:
    ffi_abi = abi == -1 ? FFI_DEFAULT_ABI : abi;
    
    for(i=0,extra_arguments=0; i<(items-5); i++)
    {
      arg = ST(i+5);
      if(!(sv_isobject(arg) && sv_derived_from(arg, "FFI::Platypus::Type")))
      {
        croak("non-type parameter passed in as type");
      }
      if(!sv_derived_from(arg, "FFI::Platypus::Type::FFI")) {
        tmp = SV2ffi_pl_type((SV*) arg);
        if(sv_derived_from(arg, "FFI::Platypus::Type::CustomPerl")) {
	  HV *hv = (HV*)SvRV(arg);
	  SV **svp;

	  svp = hv_fetch(hv, "argument_count", strlen("argument_count"), 0);
	  if (svp) {
	    extra_arguments += SvIV(*svp);
	  }
	}
      }
    }
  
    Newx(buffer, (sizeof(ffi_pl_function) + sizeof(ffi_pl_type*)*(items-5+extra_arguments)), char);
    self = (ffi_pl_function*)buffer;
    Newx(ffi_argument_types, items-5+extra_arguments, ffi_type*);
    
    self->address = address;
    self->return_type = SvREFCNT_inc(return_type_arg);
    
    if(sv_isobject(self->return_type) && sv_derived_from(self->return_type, "FFI::Platypus::Type::FFI"))
    {
      ffi_return_type = INT2PTR(ffi_type *, SvIV((SV *) SvRV((SV *)self->return_type)));
    }
    else
    {
      ffi_pl_type *return_type = SV2ffi_pl_type(self->return_type);

      if (sv_derived_from(self->return_type, "FFI::Platypus::Type::CustomPerl"))
      {
        SV *ret_in=NULL, *ret_out;
	AV *av;
	SV **svp;
	STRLEN len;
	const char *name;
	ffi_type *ffi;

	svp = hv_fetch(return_type->hv, "underlying_types", strlen("underlying_types"), 0);
	av = (AV *)SvRV(*svp);
	svp = av_fetch(av, 0, 0);
	ffi = INT2PTR(ffi_type *, SvIV((SV*)SvRV(*svp)));

        ffi_return_type = ffi;
      }
      else if (sv_derived_from(self->return_type, "FFI::Platypus::Type::ExoticFloat"))
      {
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
      self->argument_types[n] = SvREFCNT_inc(arg);

      if (sv_isobject(arg) && sv_derived_from(arg, "FFI::Platypus::Type::FFI")) {
        ffi_argument_types[n] = INT2PTR(ffi_type *, SvIV((SV *) SvRV((SV *)arg)));
      }
      else
      {
        ffi_pl_type *tmp = SV2ffi_pl_type(arg);

	if (sv_derived_from(arg, "FFI::Platypus::Type::CustomPerl"))
        {
	  HV *hv = (HV*)SvRV(arg);
	  SV **svp;
	  int d=0;

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
	    ffi = INT2PTR(ffi_type *, SvIV((SV*)SvRV(*svp)));
	    
	    self->argument_types[n+j] = arg;
	    SvREFCNT_inc(arg);
	    ffi_argument_types[n+j] = ffi;
	  }

	  n += d;
        }
	else if (sv_derived_from(arg, "FFI::Platypus::Type::ExoticFloat"))
        {
          ffi_argument_types[n] = tmp->ffi_type;
        }
        else
        {
          ffi_argument_types[n] = &ffi_type_pointer;
        }
      }
    }
    
    ffi_status = ffi_prep_cif(
      &self->ffi_cif,            /* ffi_cif     | */
      ffi_abi,                   /* ffi_abi     | */
      items-5+extra_arguments,   /* int         | argument count */
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
    
    self->platypus_sv = SvREFCNT_inc(platypus);

    RETVAL = self;
  OUTPUT:
    RETVAL

void
call(self, ...)
    ffi_pl_function *self
  PREINIT:
    char *buffer;
    size_t buffer_size;
    int i, n, perl_arg_index;
    SV *arg;
    ffi_pl_result result;
    ffi_pl_arguments *arguments;
    void **argument_pointers;
  CODE:
#define EXTRA_ARGS 1
#include "ffi_platypus_call.h"

void
attach(self, perl_name, path_name, proto)
    SV *self
    const char *perl_name
    ffi_pl_string path_name
    ffi_pl_string proto
  PREINIT:
    CV* cv;
  CODE:
    if(!(sv_isobject(self) && sv_derived_from(self, "FFI::Platypus::Function")))
      croak("self is not of type FFI::Platypus::Function");

    if(path_name == NULL)
      path_name = "unknown";

    if(proto == NULL)
      cv = newXS(perl_name, ffi_pl_sub_call, path_name);
    else
    {
      /*
       * this ifdef is needed for Perl 5.8.8 support.
       * once we don't need to support 5.8.8 we can
       * remove this workaround (the ndef'd branch)
       */
#ifdef newXS_flags
      cv = newXSproto(perl_name, ffi_pl_sub_call, path_name, proto);
#else
      newXSproto(perl_name, ffi_pl_sub_call, path_name, proto);
      cv = get_cv(perl_name,0);
#endif
    }
    CvXSUBANY(cv).any_ptr = (void *) INT2PTR(ffi_pl_function*, SvIV((SV*) SvRV(self)));
    /*
     * No coresponding decrement !!
     * once attached, you can never free the function object, or the FFI::Platypus
     * it was created from.
     */
    SvREFCNT_inc(self);

void
DESTROY(self)
    ffi_pl_function *self
  PREINIT:
    int i;
  CODE:
    SvREFCNT_dec(self->platypus_sv);
    SvREFCNT_dec(self->return_type);
    for (i=0; i<self->ffi_cif.nargs; i++) {
      SvREFCNT_dec(self->argument_types[i]);
    }
    Safefree(self->ffi_cif.arg_types);
    Safefree(self);

