#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"

#include "ffi_platypus.h"

size_t
ffi_pl_sizeof(SV *selfsv, ffi_pl_type *self)
{
  if(sv_derived_from(selfsv, "FFI::Platypus::Type::CustomPerl"))
  {
    return self->extra[0].custom_perl.size;
  }
  else if(sv_derived_from(selfsv, "FFI::Platypus::Type::FFI")
        ||sv_derived_from(selfsv, "FFI::Platypus::Type::ExoticFloat"))
  {
    return self->ffi_type->size;
  }
  else if(sv_derived_from(selfsv, "FFI::Platypus::Type::String"))
  {
    if(self->extra[0].string.platypus_string_type == FFI_PL_STRING_FIXED)
      return self->extra[0].string.size;
    else
      return sizeof(void*);
  }
  else if(sv_derived_from(selfsv, "FFI::Platypus::Type::Pointer")
        ||sv_derived_from(selfsv, "FFI::Platypus::Type::Closure"))
  {
    return sizeof(void*);
  }
  else if(sv_derived_from(selfsv, "FFI::Platypus::Type::Array"))
  {
    return self->ffi_type->size * self->extra[0].array.element_count;
  }
  else if(sv_derived_from(selfsv, "FFI::Platypus::Type::Record"))
  {
    return self->extra[0].record.size;
  }
  else
  {
    return 0;
  }
}

HV *
ffi_pl_ffi_get_type_meta(ffi_type *ffi_type)
{
  const char *string;
  HV *meta = newHV();

  hv_store(meta, "size", 4, newSViv(ffi_type->size), 0);

  hv_store(meta, "element_size", 12, newSViv(ffi_type->size), 0);
  hv_store(meta, "type",          4, newSVpv("scalar",0),0);

  switch(ffi_type->type)
    {
    case FFI_TYPE_VOID:
      hv_store(meta, "element_type", 12, newSVpv("void",0),0);
      break;
    case FFI_TYPE_FLOAT:
    case FFI_TYPE_DOUBLE:
    case FFI_TYPE_LONGDOUBLE:
#ifdef FFI_TARGET_HAS_COMPLEX_TYPE
    case FFI_TYPE_COMPLEX:
#endif
      hv_store(meta, "element_type", 12, newSVpv("float",0),0);
      break;
    case FFI_TYPE_UINT8:
    case FFI_TYPE_UINT16:
    case FFI_TYPE_UINT32:
    case FFI_TYPE_UINT64:
      hv_store(meta, "element_type", 12, newSVpv("int",0),0);
      hv_store(meta, "sign",          4, newSViv(0),0);
      break;
    case FFI_TYPE_SINT8:
    case FFI_TYPE_SINT16:
    case FFI_TYPE_SINT32:
    case FFI_TYPE_SINT64:
      hv_store(meta, "element_type", 12, newSVpv("int",0),0);
      hv_store(meta, "sign",          4, newSViv(1),0);
      break;
    case FFI_TYPE_POINTER:
      hv_store(meta, "element_type", 12, newSVpv("opaque",0),0);
      break;
  }
  switch(ffi_type->type)
  {
    case FFI_TYPE_VOID:
      string = "void";
      break;
    case FFI_TYPE_FLOAT:
      string = "float";
      break;
    case FFI_TYPE_DOUBLE:
      string = "double";
      break;
    case FFI_TYPE_LONGDOUBLE:
      string = "longdouble";
      break;
    case FFI_TYPE_UINT8:
      string = "uint8";
      break;
    case FFI_TYPE_SINT8:
      string = "sint8";
      break;
    case FFI_TYPE_UINT16:
      string = "uint16";
      break;
    case FFI_TYPE_SINT16:
      string = "sint16";
      break;
    case FFI_TYPE_UINT32:
      string = "uint32";
      break;
    case FFI_TYPE_SINT32:
      string = "sint32";
      break;
    case FFI_TYPE_UINT64:
      string = "uint64";
      break;
    case FFI_TYPE_SINT64:
      string = "sint64";
      break;
    case FFI_TYPE_POINTER:
      string = "pointer";
      break;
#ifdef FFI_TARGET_HAS_COMPLEX_TYPE
    case FFI_TYPE_COMPLEX:
      string = ffi_type->size == 16 ? "complex_double" : "complex_float";
      break;
#endif
    default:
      string = NULL;
      break;
  }
  hv_store(meta, "ffi_type", 8, newSVpv(string,0),0);

  return meta;
}

HV *
ffi_pl_get_type_meta(SV *selfsv)
{
  ffi_pl_type *self;
  HV *meta;
  const char *string;

  meta = newHV();

  if(sv_isobject(selfsv) && sv_derived_from(selfsv, "FFI::Platypus::Type")) {
    HV *hv = (HV*)SvRV(selfsv);
    SV **svp = hv_fetch(hv, "ffi_pl_type", strlen("ffi_pl_type"), 0);
    if (svp == NULL)
      Perl_croak(aTHX_ "self is missing the ffi_pl_type hash entry");
    self = INT2PTR(ffi_pl_type *, SvIV((SV*)SvRV(*svp)));
  } else
    Perl_croak(aTHX_ "self is not of type FFI::Platypus::Type");

  hv_store(meta, "size", 4, newSViv(ffi_pl_sizeof(selfsv, self)), 0);

  if(sv_derived_from(selfsv, "FFI::Platypus::Type::FFI") || sv_derived_from(selfsv, "FFI::Platypus::Type::ExoticFloat"))
  {
    hv_store(meta, "element_size", 12, newSViv(self->ffi_type->size), 0);
    hv_store(meta, "type",          4, newSVpv("scalar",0),0);
    if(sv_derived_from(selfsv, "FFI::Platypus::Type::ExoticFloat"))
      hv_store(meta, "exotic", 6, newSViv(1), 0);
  }
  else if(sv_derived_from(selfsv, "FFI::Platypus::Type::String"))
  {
    hv_store(meta, "element_size",  12, newSViv(sizeof(void*)), 0);
    hv_store(meta, "type",           4, newSVpv("string",0),0);
    switch(self->extra[0].string.platypus_string_type)
    {
      case FFI_PL_STRING_RO:
        hv_store(meta, "access",        6, newSVpv("ro",0), 0);
        hv_store(meta, "fixed_size",    10, newSViv(0), 0);
        break;
      case FFI_PL_STRING_RW:
        hv_store(meta, "access",        6, newSVpv("rw",0), 0);
        hv_store(meta, "fixed_size",    10, newSViv(0), 0);
        break;
      case FFI_PL_STRING_FIXED:
        hv_store(meta, "access",        6, newSVpv("rw",0), 0);
        hv_store(meta, "fixed_size",    10, newSViv(1), 0);
        break;
    }
  }
  else if(sv_derived_from(selfsv, "FFI::Platypus::Type::Pointer"))
  {
    hv_store(meta, "element_size", 12, newSViv(self->ffi_type->size), 0);
    hv_store(meta, "type",          4, newSVpv("pointer",0),0);
  }
  else if(sv_derived_from(selfsv, "FFI::Platypus::Type::Array"))
  {
    hv_store(meta, "element_size",  12, newSViv(self->ffi_type->size), 0);
    hv_store(meta, "type",           4, newSVpv("array",0),0);
    hv_store(meta, "element_count", 13, newSViv(self->extra[0].array.element_count), 0);
  }
  else if(sv_derived_from(selfsv, "FFI::Platypus::Type::Closure"))
  {
    AV *signature;
    AV *argument_types;
    HV *subtype;
    SV *rettype;
    int i;
    int number_of_arguments;

    number_of_arguments = self->extra[0].closure.ffi_cif.nargs;

    signature = newAV();
    argument_types = newAV();

    for(i=0; i < number_of_arguments; i++)
    {
      dSP;
      int count;
      SV *argtype = self->extra[0].closure.argument_types[i];

      ENTER;
      SAVETMPS;
      PUSHMARK(SP);
      XPUSHs(argtype);
      PUTBACK;

      count = call_method("meta", G_SCALAR);

      SPAGAIN;
      if (count == 1)
	av_store(argument_types, i, SvREFCNT_inc(POPs));

      PUTBACK;
      FREETMPS;
      LEAVE;
    }
    av_store(signature, 0, newRV_noinc((SV*)argument_types));

    {
      dSP;
      int count;

      rettype = self->extra[0].closure.return_type;
      ENTER;
      SAVETMPS;
      PUSHMARK(SP);
      XPUSHs(rettype);
      PUTBACK;

      count = call_method("meta", G_SCALAR);

      SPAGAIN;
      if (count == 1)
	av_store(signature, 1, SvREFCNT_inc(POPs));

      PUTBACK;
      FREETMPS;
      LEAVE;
    }

    hv_store(meta, "signature",     9, newRV_noinc((SV*)signature), 0);

    hv_store(meta, "element_size", 12, newSViv(sizeof(void*)), 0);
    hv_store(meta, "type",          4, newSVpv("closure",0),0);
  }
  else if(sv_derived_from(selfsv, "FFI::Platypus::Type::CustomPerl"))
  {
    HV *hv = (HV*)SvRV(selfsv);
    SV **svp;

    hv_store(meta, "type",          4, newSVpv("custom_perl",0),0);

    svp = hv_fetch(hv, "perl_to_native", strlen("perl_to_native"), 0);
    if (svp) {
      hv_store(meta, "custom_perl_to_native", 18, newRV_inc(*svp), 0);
    }

    svp = hv_fetch(hv, "perl_to_native_post", strlen("perl_to_native_post"), 0);
    if (svp) {
      hv_store(meta, "custom_perl_to_native", 23, newRV_inc(*svp), 0);
    }

    svp = hv_fetch(hv, "native_to_perl", strlen("native_to_perl"), 0);
    if (svp) {
      hv_store(meta, "custom_native_to_perl", 18, newRV_inc(*svp), 0);
    }

    svp = hv_fetch(hv, "argument_count", strlen("argument_count"), 0);
    if (svp) {
      hv_store(meta, "argument_count", strlen("argument_count"), newSViv(SvIV(*svp) + 1), 0);
    }
  }
  else if(sv_derived_from(selfsv, "FFI::Platypus::Type::Record"))
  {
    hv_store(meta, "type",          4, newSVpv("record",0),0);
    hv_store(meta, "ref",           3, newSViv(self->extra[0].record.stash != NULL ? 1 : 0),0);
  }

  ffi_type *ffi_type;
  ffi_type = self->ffi_type;
  if (self->ffi_type == NULL) {
    AV *av;
    SV **svp;
    STRLEN len;
    const char *name;
    svp = hv_fetch(self->hv, "underlying_types", strlen("underlying_types"), 0);
    av = (AV *)SvRV(*svp);
    svp = av_fetch(av, 0, 0);
    name = SvPV(*svp, len);
    ffi_type = ffi_pl_name_to_type(name);
  }

  switch(ffi_type->type)
    {
    case FFI_TYPE_VOID:
      hv_store(meta, "element_type", 12, newSVpv("void",0),0);
      break;
    case FFI_TYPE_FLOAT:
    case FFI_TYPE_DOUBLE:
    case FFI_TYPE_LONGDOUBLE:
#ifdef FFI_TARGET_HAS_COMPLEX_TYPE
    case FFI_TYPE_COMPLEX:
#endif
      hv_store(meta, "element_type", 12, newSVpv("float",0),0);
      break;
    case FFI_TYPE_UINT8:
    case FFI_TYPE_UINT16:
    case FFI_TYPE_UINT32:
    case FFI_TYPE_UINT64:
      hv_store(meta, "element_type", 12, newSVpv("int",0),0);
      hv_store(meta, "sign",          4, newSViv(0),0);
      break;
    case FFI_TYPE_SINT8:
    case FFI_TYPE_SINT16:
    case FFI_TYPE_SINT32:
    case FFI_TYPE_SINT64:
      hv_store(meta, "element_type", 12, newSVpv("int",0),0);
      hv_store(meta, "sign",          4, newSViv(1),0);
      break;
    case FFI_TYPE_POINTER:
      hv_store(meta, "element_type", 12, newSVpv("opaque",0),0);
      break;
  }
  switch(ffi_type->type)
  {
    case FFI_TYPE_VOID:
      string = "void";
      break;
    case FFI_TYPE_FLOAT:
      string = "float";
      break;
    case FFI_TYPE_DOUBLE:
      string = "double";
      break;
    case FFI_TYPE_LONGDOUBLE:
      string = "longdouble";
      break;
    case FFI_TYPE_UINT8:
      string = "uint8";
      break;
    case FFI_TYPE_SINT8:
      string = "sint8";
      break;
    case FFI_TYPE_UINT16:
      string = "uint16";
      break;
    case FFI_TYPE_SINT16:
      string = "sint16";
      break;
    case FFI_TYPE_UINT32:
      string = "uint32";
      break;
    case FFI_TYPE_SINT32:
      string = "sint32";
      break;
    case FFI_TYPE_UINT64:
      string = "uint64";
      break;
    case FFI_TYPE_SINT64:
      string = "sint64";
      break;
    case FFI_TYPE_POINTER:
      string = "pointer";
      break;
#ifdef FFI_TARGET_HAS_COMPLEX_TYPE
    case FFI_TYPE_COMPLEX:
      string = ffi_type->size == 16 ? "complex_double" : "complex_float";
      break;
#endif
    default:
      string = NULL;
      break;
  }
  hv_store(meta, "ffi_type", 8, newSVpv(string,0),0);

  return meta;
}
