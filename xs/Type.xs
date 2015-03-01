MODULE = FFI::Platypus PACKAGE = FFI::Platypus::Type

SV *
_new(class, type, platypus_type, array_or_record_or_string_size, type_classname, rw)
    const char *class
    const char *type
    const char *platypus_type
    size_t array_or_record_or_string_size
    ffi_pl_string type_classname
    int rw
  PREINIT:
    ffi_pl_type *self;
    char *buffer;
  CODE:
    self = NULL;
    if(!strcmp(platypus_type, "string"))
    {
      Newx(buffer, sizeof(ffi_pl_type) + sizeof(ffi_pl_type_extra_string), char);
      self = (ffi_pl_type*) buffer;
      self->hv = NULL;
      self->ffi_type = NULL;
      self->extra[0].string.size = array_or_record_or_string_size;
      if(array_or_record_or_string_size == 0)
      {
        self->extra[0].string.platypus_string_type = rw ? FFI_PL_STRING_RW : FFI_PL_STRING_RO;
      }
      else
      {
        self->extra[0].string.platypus_string_type = FFI_PL_STRING_FIXED;
      }
    }
    else if(!strcmp(platypus_type, "ffi"))
    {
      Newx(self, 1, ffi_pl_type);
      self->hv = NULL;
      self->ffi_type = NULL;
      if(!strcmp(type, "longdouble"))
      {
        if(have_math_longdouble == -1)
          have_math_longdouble = have_pm("Math::LongDouble");
      }
      else if(!strcmp(type, "complex_float")
      ||    !strcmp(type, "complex_double"))
      {
        if(have_math_complex == -1)
          have_math_complex = have_pm("Math::Complex");
      }
    }
    else if(!strcmp(platypus_type, "pointer"))
    {
      Newx(self, 1, ffi_pl_type);
      self->hv = NULL;
      self->ffi_type = NULL;
    }
    else if(!strcmp(platypus_type, "array"))
    {
      Newx(buffer, sizeof(ffi_pl_type) + sizeof(ffi_pl_type_extra_array), char);
      self = (ffi_pl_type*) buffer;
      self->hv = NULL;
      self->ffi_type = NULL;
      self->extra[0].array.element_count = array_or_record_or_string_size;
    }
    else if(!strcmp(platypus_type, "record"))
    {
      Newx(buffer, sizeof(ffi_pl_type) + sizeof(ffi_pl_type_extra_record), char);
      self = (ffi_pl_type*) buffer;
      self->hv = NULL;
      self->ffi_type = NULL;
      self->extra[0].record.size = array_or_record_or_string_size;
      self->extra[0].record.stash = type_classname != NULL ? gv_stashpv(type_classname, GV_ADD) : NULL;
    }
    else
    {
      croak("unknown ffi/platypus type: %s/%s", type, platypus_type);
    }

    if(self != NULL && self->ffi_type == NULL)
    {
      self->ffi_type = ffi_pl_name_to_type(type);
      if(self->ffi_type == NULL)
      {
        Safefree(self);
        self = NULL;
        croak("unknown ffi/platypus type: %s/%s", type, platypus_type);
      }
    }

    do
    {
      HV *hv;
      SV *sv = newSV(0);
      HV *stash = gv_stashpv(class, GV_ADD);
      hv = self->hv;
      if (!hv)
      {
        hv = newHV();
        self->hv = hv;
      }
      sv_setref_pv(sv, "FFI::Platypus::Type::C", (void *) self);
      hv_store(hv, "ffi_pl_type", strlen("ffi_pl_type"), sv, 0);
      RETVAL = newRV_inc((SV*)hv);
      sv_bless(RETVAL, stash);
    }
    while(0);
  OUTPUT:
    RETVAL

ffi_pl_type *
_new_custom_perl(class, types, size, perl_to_native, native_to_perl, perl_to_native_post, in_argument_count, out_argument_count)
    const char *class
    SV *types
    size_t size
    SV *perl_to_native
    SV *native_to_perl
    SV *perl_to_native_post
    int in_argument_count
    int out_argument_count
  PREINIT:
    char *buffer;
    ffi_pl_type *self;
    ffi_type *ffi_type;
    ffi_pl_type_extra_custom_perl *custom;
  CODE:
    Newx(buffer, sizeof(ffi_pl_type) + sizeof(ffi_pl_type_extra_custom_perl), char);
    self = (ffi_pl_type*) buffer;
    self->hv = newHV();
    self->ffi_type = NULL;
    hv_store((HV *)self->hv, "underlying_types", strlen("underlying_types"), SvREFCNT_inc(types), 0);

    custom = &self->extra[0].custom_perl;
    custom->size = size;
    if(SvOK(perl_to_native))
      hv_store((HV *)self->hv, "perl_to_native", strlen("perl_to_native"), SvREFCNT_inc(perl_to_native), 0);
    if(SvOK(perl_to_native_post))
      hv_store((HV *)self->hv, "perl_to_native_post", strlen("perl_to_native_post"), SvREFCNT_inc(perl_to_native_post), 0);
    if(SvOK(native_to_perl))
      hv_store((HV *)self->hv, "native_to_perl", strlen("native_to_perl"), SvREFCNT_inc(native_to_perl), 0);
    if(out_argument_count != 1)
      hv_store((HV *)self->hv, "argument_count", strlen("argument_count"), newSViv(out_argument_count-1), 0);
    hv_store((HV *)self->hv, "in_argument_count", strlen("in_argument_count"), newSViv(in_argument_count), 0);
    
    RETVAL = self;
  OUTPUT:
    RETVAL


ffi_pl_type *
_new_constant(class, types, size, value)
    const char *class
    SV *types
    size_t size
    SV *value
  PREINIT:
    ffi_pl_type *self;
    ffi_type *ffi_type;
    ffi_pl_type_extra_custom_perl *custom;
  CODE:
    Newx(self, 1, ffi_pl_type);
    self->hv = newHV();
    self->ffi_type = NULL;
    hv_store((HV *)self->hv, "underlying_types", strlen("underlying_types"), SvREFCNT_inc(types), 0);

    if(SvOK(value))
      hv_store((HV *)self->hv, "value", strlen("value"), SvREFCNT_inc(value), 0);

    RETVAL = self;
  OUTPUT:
    RETVAL


ffi_pl_type *
_new_struct_type(class, types)
    const char *class
    SV *types
  PREINIT:
    ffi_pl_type *self;
    SV *ffi_sv;
    SV *ffi_children_sv;
    ffi_type *ffi;
    ffi_type **ffi_children;
    ffi_pl_type_extra_custom_perl *custom;
    int perl_n;
    int ffi_n;
    int i,j;
  CODE:
    Newx(self, 1, ffi_pl_type);
    self->hv = newHV();

    hv_store((HV *)self->hv, "underlying_types", strlen("underlying_types"), SvREFCNT_inc(types), 0);

    perl_n = av_len((AV*)SvRV(types)) + 1;

    ffi_n = 0;
    for(i=0; i<perl_n; i++)
    {
      SV *type;
      SV **svp;
      svp = av_fetch((AV *)SvRV(types), i, 0);
      type = *svp;

      if(sv_derived_from(type, "FFI::Platypus::Type::CustomPerl"))
	ffi_n += ffi_pl_customperl_count_native_arguments(type);
      else
	ffi_n++;
    }

    ffi_sv = newSV(sizeof(*ffi));
    hv_store((HV *)self->hv, "ffi_type", strlen("ffi_type"), ffi_sv, 0);
    ffi = SvPV_nolen(ffi_sv);

    ffi_children_sv =  newSV((ffi_n+1)*sizeof *ffi_children);
    hv_store((HV *)self->hv, "ffi_children", strlen("ffi_children"), ffi_children_sv, 0);
    ffi_children = SvPV_nolen(ffi_children_sv);

    for(i=0, j=0; i<perl_n; i++,j++)
    {
      SV **svp;
      svp = av_fetch((AV *)SvRV(types), i, 0);

      if(sv_derived_from(*svp, "FFI::Platypus::Type::FFI"))
      {
	ffi = INT2PTR(ffi_type *, SvIV((SV*)SvRV(*svp)));

	ffi_children[j] = ffi;
      }
      else if(sv_derived_from(*svp, "FFI::Platypus::Type::Array"))
      {
	ffi = &ffi_type_pointer;

	ffi_children[j] = ffi;
      }
      else if(sv_derived_from(*svp, "FFI::Platypus::Type::CustomPerl"))
      {
	int d2 = ffi_pl_prepare_customperl(NULL, 0, ffi_children, j, *svp);

	j += d2-1;
      }
      else
      {
	ffi = SV2ffi_pl_type(*svp)->ffi_type;

	ffi_children[j] = ffi;
      }
    }

    ffi_children[ffi_n] = NULL;

    ffi->size = ffi->alignment = 0;
    ffi->type = FFI_TYPE_STRUCT;
    ffi->elements = ffi_children;

    self->ffi_type = ffi;

    RETVAL = self;
  OUTPUT:
    RETVAL


ffi_pl_type *
_new_closure(class, return_type_arg, ...)
    const char *class;
    SV *return_type_arg;
  PREINIT:
    char *buffer;
    ffi_pl_type *self;
    int i;
    SV *arg;
    ffi_type *ffi_return_type;
    ffi_type **ffi_argument_types;
    ffi_status ffi_status;
  CODE:
    if (!sv_isobject(return_type_arg) ||
        !sv_derived_from(return_type_arg, "FFI::Platypus::Type::FFI")) {
      croak("Only native types are supported as closure return types");
    }

    ffi_return_type = INT2PTR(ffi_type *, SvIV((SV *) SvRV(return_type_arg)));

    for(i=0; i<(items-2); i++)
    {
      arg = ST(2+i);
      if (!sv_isobject(arg) ||
          (!sv_derived_from(arg, "FFI::Platypus::Type::FFI") &&
	   !sv_derived_from(arg, "FFI::Platypus::Type::String"))) {
	croak("Only native types and strings are supported as closure argument types");
      }
    }
    
    Newx(buffer, sizeof(ffi_pl_type) + sizeof(ffi_pl_type_extra_closure) + sizeof(ffi_pl_type)*(items-2), char);
    Newx(ffi_argument_types, items-2, ffi_type*);
    self = (ffi_pl_type*) buffer;
    
    self->hv = NULL;
    self->ffi_type = &ffi_type_pointer;
    self->extra[0].closure.return_type = SvREFCNT_inc(return_type_arg);
    self->extra[0].closure.flags = 0;
    
    for(i=0; i<(items-2); i++)
    {
      arg = ST(2+i);
      self->extra[0].closure.argument_types[i] = SvREFCNT_inc(arg);

      if (!sv_isobject(arg) ||
          !sv_derived_from(arg, "FFI::Platypus::Type::FFI"))
      {
	ffi_pl_type *tmp = SV2ffi_pl_type(arg);

	ffi_argument_types[i] = &ffi_type_pointer;
      }
      else
      {
	ffi_argument_types[i] = INT2PTR(ffi_type *, SvIV((SV *) SvRV(arg)));
      }
    }
    
    ffi_status = ffi_prep_cif(
      &self->extra[0].closure.ffi_cif,
      FFI_DEFAULT_ABI,
      items-2,
      ffi_return_type,
      ffi_argument_types
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

    if( items-2 == 0 )
    {
      self->extra[0].closure.flags |= G_NOARGS;
    }

    if(ffi_return_type == FFI_TYPE_VOID)
    {
      self->extra[0].closure.flags |= G_DISCARD | G_VOID;
    }
    else
    {
      self->extra[0].closure.flags |= G_SCALAR;
    }
    
    RETVAL = self;
    
  OUTPUT:
    RETVAL

SV*
meta(self)
    SV *self
  PREINIT:
    HV *meta;
  CODE:
    meta = ffi_pl_get_type_meta(self);
    RETVAL = newRV_noinc((SV*)meta);
  OUTPUT:
    RETVAL

int
sizeof(selfsv)
    SV *selfsv
  CODE:
    RETVAL = ffi_pl_sizeof(selfsv, SV2ffi_pl_type(selfsv));
  OUTPUT:
    RETVAL

MODULE = FFI::Platypus PACKAGE = FFI::Platypus::Type::C

void
DESTROY(self_sv)
    SV *self_sv
  PREINIT:
    int i;
    ffi_pl_type *self;
  CODE:
    self = INT2PTR(ffi_pl_type *, SvIV((SV *)SvRV(self_sv)));
/* XXX
    if(self->platypus_type == FFI_PL_CLOSURE)
    {
      SvREFCNT_dec(self->extra[0].closure.return_type);
      for (i=0; i<self->extra[0].closure.ffi_cif.nargs; i++) {
	SvREFCNT_dec(self->extra[0].closure.argument_types[i]);
      }
      Safefree(self->extra[0].closure.ffi_cif.arg_types);
    }
    else if(self->platypus_type == FFI_PL_CUSTOM_PERL)
    {
      ffi_pl_type_extra_custom_perl *custom;
      
      custom = &self->extra[0].custom_perl;
      
      if(custom->perl_to_native != NULL)
        SvREFCNT_dec(custom->perl_to_native);
      if(custom->perl_to_native_post != NULL)
        SvREFCNT_dec(custom->perl_to_native_post);
      if(custom->native_to_perl != NULL)
        SvREFCNT_dec(custom->native_to_perl);
    }
*/
    Safefree(self);

MODULE = FFI::Platypus PACKAGE = FFI::Platypus::Type::StringPointer

void
native_to_perl_xs(pointer)
    SV *pointer
  PREINIT:
    const char **string_c;
    SV *string_perl;
  CODE:
    /* we currently use the pp version instead */
    if(SvOK(pointer))
    {
      string_c = INT2PTR(const char**,SvIV(pointer));
      if(*string_c != NULL)
      {
        string_perl = sv_newmortal();
        sv_setpv(string_perl, *string_c);
        ST(0) = newRV_inc(string_perl);
      }
      else
      {
        ST(0) = newRV_noinc(&PL_sv_undef);
      }
      XSRETURN(1);
    }
    else
    {
      XSRETURN_EMPTY;
    }

MODULE = FFI::Platypus PACKAGE = FFI::Platypus::Type::FFI

ffi_type*
new(class, name)
    const char *class
    const char *name
  CODE:
    RETVAL = ffi_pl_name_to_type(name);
  OUTPUT:
    RETVAL

size_t
sizeof(self)
    ffi_type *self
  CODE:
    RETVAL = self->size;
  OUTPUT:
    RETVAL

SV*
meta(self)
    ffi_type *self
  PREINIT:
    HV *meta;
  CODE:
    meta = ffi_pl_ffi_get_type_meta(self);
    RETVAL = newRV_noinc((SV*)meta);
  OUTPUT:
    RETVAL
