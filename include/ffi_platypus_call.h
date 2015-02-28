#undef HAVE_ALLOCA
    /* buffer contains the memory required for the arguments structure */
    buffer_size = sizeof(ffi_pl_argument) * self->ffi_cif.nargs +
                  sizeof(void*) * self->ffi_cif.nargs +
                  sizeof(ffi_pl_arguments);
#ifdef HAVE_ALLOCA
    buffer = alloca(buffer_size);
#else
    Newx(buffer, buffer_size, char);
#endif
    current_argv = arguments = (ffi_pl_arguments*) buffer;

    arguments->count = self->ffi_cif.nargs;
    argument_pointers = (void**) &arguments->slot[arguments->count];

    /*
     * ARGUMENT IN
     */

    for(i=0, perl_type_index=0, perl_arg_index=EXTRA_ARGS; i < self->ffi_cif.nargs; i++, perl_type_index++)
    {
      SV *type_sv = self->argument_getters[perl_type_index].sv;
      int perl_args = self->argument_getters[perl_type_index].perl_args;
      int native_args = self->argument_getters[perl_type_index].native_args;
      int count;

      argument_pointers[i] = (void*) &arguments->slot[i];
      if(perl_args == 1)
      {
	arg = perl_arg_index < items ? ST(perl_arg_index) : &PL_sv_undef;
	perl_arg_index++;
      }
      else
      {
	arg = (SV*)newAV();
	for(n=0; n<perl_args; n++) {
	  av_push((AV *)arg, perl_arg_index < items ? ST(perl_arg_index) : &PL_sv_undef);
	  perl_arg_index++;
	}
      }

      count = self->argument_getters[perl_type_index].perl_to_native(arguments, i, type_sv, arg, argument_pointers);

      for(n=0; n<count-1; n++) {
	i++;
	argument_pointers[i] = &arguments->slot[i];
      }
    }

  /*
   * CALL
   */

#if 0
  fprintf(stderr, "# ===[%p]===\n", self->address);
  for(i=0; i < self->ffi_cif.nargs; i++)
  {
    fprintf(stderr, "# [%d] <%d:%d> %p %p",
      i,
      type->ffi_type->type,
      type->platypus_type,
      argument_pointers[i],
      &arguments->slot[i]
    );
    if(type->platypus_type  == FFI_PL_EXOTIC_FLOAT)
    {
      switch(type->ffi_type->type)
      {
        case FFI_TYPE_LONGDOUBLE:
          fprintf(stderr, " %Lg", *((long double*)argument_pointers[i]));
          break;
        case FFI_TYPE_COMPLEX:
          switch(type->ffi_type->size)
          {
            case 8:
              fprintf(stderr, " %g + %g * i",
                crealf(*((float complex*)argument_pointers[i])),
                cimagf(*((float complex*)argument_pointers[i]))
              );
              break;
            case 16:
              fprintf(stderr, " %g + %g * i",
                creal(*((double complex*)argument_pointers[i])),
                cimag(*((double complex*)argument_pointers[i]))
              );
              break;
          }
      }
    }
    else
    {
      fprintf(stderr, "%016llx", ffi_pl_arguments_get_uint64(arguments, i));
    }
    fprintf(stderr, "\n");
  }
  fprintf(stderr, "# === ===\n");
  fflush(stderr);
#endif

  current_argv = NULL;

  if(self->address != NULL)
  {
    ffi_call(&self->ffi_cif, self->address, &result, ffi_pl_arguments_pointers(arguments));
  }
  else
  {
    void *address = self->ffi_cif.nargs > 0 ? (void*) &cast1 : (void*) &cast0;
    ffi_call(&self->ffi_cif, address, &result, ffi_pl_arguments_pointers(arguments));
  }

  /*
   * ARGUMENT OUT
   */

  current_argv = arguments;

  for(i=self->ffi_cif.nargs,perl_arg_index--,perl_type_index--; i > 0; perl_type_index--)
  {
    SV *type_sv = self->argument_getters[perl_type_index].sv;
    int perl_args = self->argument_getters[perl_type_index].perl_args;
    int native_args = self->argument_getters[perl_type_index].native_args;
    int count;

    if(perl_args == 1)
    {
      arg = perl_arg_index < items ? ST(perl_arg_index) : &PL_sv_undef;
      perl_arg_index--;
    }
    else
    {
      /* this is not a valid AV. We only use it to keep track of a
	 number of SV *s, which we know are alive during the lifetime
	 of the AV. Thus, no refcounting. */
      arg = (SV*)newAV();
      for(n=0; n<perl_args; n++) {
	av_push((AV *)arg, perl_arg_index < items ? ST(perl_arg_index) : &PL_sv_undef);
	perl_arg_index--;
      }
    }
    count = self->argument_getters[perl_type_index].perl_to_native_post(arguments, i, type_sv, arg, argument_pointers);

    i -= count;
  }

#ifndef HAVE_ALLOCA
  if(!sv_derived_from(self->return_type, "FFI::Platypus::Type::CustomPerl"))
    Safefree(arguments);
#endif

  current_argv = NULL;

    /*
     * RETURN VALUE
     */

    SV *return_type = self->return_type;

    if(sv_derived_from(return_type, "FFI::Platypus::Type::FFI")) {
      ffi_type *ffi = INT2PTR(ffi_type *, SvIV((SV *) SvRV(return_type)));
      int type = ffi->type;
      if(type == FFI_TYPE_VOID || (type == FFI_TYPE_POINTER && result.pointer == NULL))
      {
        XSRETURN_EMPTY;
      }
      else
      {
        switch(ffi->type)
        {
          case FFI_TYPE_UINT8:
#ifdef FFI_PL_PROBE_BIGENDIAN
            XSRETURN_UV(result.uint8_array[3]);
#else
            XSRETURN_UV(result.uint8);
#endif
            break;
          case FFI_TYPE_SINT8:
#ifdef FFI_PL_PROBE_BIGENDIAN
            XSRETURN_IV(result.sint8_array[3]);
#else
            XSRETURN_IV(result.sint8);
#endif
            break;
          case FFI_TYPE_UINT16:
#ifdef FFI_PL_PROBE_BIGENDIAN
            XSRETURN_UV(result.uint16_array[1]);
#else
            XSRETURN_UV(result.uint16);
#endif
            break;
          case FFI_TYPE_SINT16:
#ifdef FFI_PL_PROBE_BIGENDIAN
            XSRETURN_IV(result.sint16_array[1]);
#else
            XSRETURN_IV(result.sint16);
#endif
            break;
          case FFI_TYPE_UINT32:
            XSRETURN_UV(result.uint32);
            break;
          case FFI_TYPE_SINT32:
            XSRETURN_IV(result.sint32);
            break;
          case FFI_TYPE_UINT64:
#ifdef HAVE_IV_IS_64
            XSRETURN_UV(result.uint64);
#else
            {
              ST(0) = sv_newmortal();
              sv_setu64(ST(0), result.uint64);
              XSRETURN(1);
            }
#endif
            break;
          case FFI_TYPE_SINT64:
#ifdef HAVE_IV_IS_64
            XSRETURN_IV(result.sint64);
#else
            {
              ST(0) = sv_newmortal();
              sv_seti64(ST(0), result.uint64);
              XSRETURN(1);
            }
#endif
            break;
          case FFI_TYPE_FLOAT:
            XSRETURN_NV(result.xfloat);
            break;
          case FFI_TYPE_DOUBLE:
            XSRETURN_NV(result.xdouble);
            break;
          case FFI_TYPE_POINTER:
            XSRETURN_IV(PTR2IV(result.pointer));
            break;
        }
      }
    } else {
      ffi_pl_type *pl_return_type = SV2ffi_pl_type(return_type);
      if(sv_derived_from(return_type, "FFI::Platypus::Type::String"))
      {
        if(result.pointer == NULL)
        {
          XSRETURN_EMPTY;
        }
        else
        {
          if(pl_return_type->extra[0].string.platypus_string_type == FFI_PL_STRING_FIXED)
          {
            SV *value = sv_newmortal();
            sv_setpvn(value, result.pointer, pl_return_type->extra[0].string.size);
            ST(0) = value;
            XSRETURN(1);
          }
          else
          {
            XSRETURN_PV(result.pointer);
          }
        }
      }
      else if(sv_derived_from(return_type, "FFI::Platypus::Type::Pointer"))
      {
        if(result.pointer == NULL)
        {
          XSRETURN_EMPTY;
        }
        else
        {
          SV *value;
          switch(pl_return_type->ffi_type->type)
          {
            case FFI_TYPE_UINT8:
              value = sv_newmortal();
              sv_setuv(value, *((uint8_t*) result.pointer));
              break;
            case FFI_TYPE_SINT8:
              value = sv_newmortal();
              sv_setiv(value, *((int8_t*) result.pointer));
              break;
            case FFI_TYPE_UINT16:
              value = sv_newmortal();
              sv_setuv(value, *((uint16_t*) result.pointer));
              break;
            case FFI_TYPE_SINT16:
              value = sv_newmortal();
              sv_setiv(value, *((int16_t*) result.pointer));
              break;
            case FFI_TYPE_UINT32:
              value = sv_newmortal();
              sv_setuv(value, *((uint32_t*) result.pointer));
              break;
            case FFI_TYPE_SINT32:
              value = sv_newmortal();
              sv_setiv(value, *((int32_t*) result.pointer));
              break;
            case FFI_TYPE_UINT64:
              value = sv_newmortal();
#ifdef HAVE_IV_IS_64
              sv_setuv(value, *((uint64_t*) result.pointer));
#else
              sv_seti64(value, *((int64_t*) result.pointer));
#endif
              break;
            case FFI_TYPE_SINT64:
              value = sv_newmortal();
#ifdef HAVE_IV_IS_64
              sv_setiv(value, *((int64_t*) result.pointer));
#else
              sv_seti64(value, *((int64_t*) result.pointer));
#endif
              break;
            case FFI_TYPE_FLOAT:
              value = sv_newmortal();
              sv_setnv(value, *((float*) result.pointer));
              break;
            case FFI_TYPE_DOUBLE:
              value = sv_newmortal();
              sv_setnv(value, *((double*) result.pointer));
              break;
            case FFI_TYPE_POINTER:
              value = sv_newmortal();
              if( *((void**)result.pointer) == NULL )
                value = &PL_sv_undef;
              else
                sv_setiv(value, PTR2IV(*((void**)result.pointer)));
              break;
#ifdef FFI_PL_PROBE_LONGDOUBLE
            case FFI_TYPE_LONGDOUBLE:
              value = sv_newmortal();
              ffi_pl_long_double_to_perl(value, (long double*)result.pointer);
              break;
#endif
            default:
              warn("return type not supported");
              XSRETURN_EMPTY;
          }
          ST(0) = newRV_inc(value);
          XSRETURN(1);
        }
      }
      else if(sv_derived_from(return_type, "FFI::Platypus::Type::Record"))
      {
        if(result.pointer != NULL)
        {
          SV *value = sv_newmortal();
          sv_setpvn(value, result.pointer, pl_return_type->extra[0].record.size);
          if(pl_return_type->extra[0].record.stash)
          {
            SV *ref = ST(0) = newRV_inc(value);
            sv_bless(ref, pl_return_type->extra[0].record.stash);
          }
          else
          {
            ST(0) = value;
          }
          XSRETURN(1);
        }
        else
        {
          XSRETURN_EMPTY;
        }
      }
      else if(sv_derived_from(return_type, "FFI::Platypus::Type::Array"))
      {
        if(result.pointer == NULL)
        {
          XSRETURN_EMPTY;
        }
        else
        {
          int count = pl_return_type->extra[0].array.element_count;
          AV *av;
          SV **sv;
          Newx(sv, count, SV*);
          switch(pl_return_type->ffi_type->type)
          {
            case FFI_TYPE_UINT8:
              for(i=0; i<count; i++)
              {
                sv[i] = newSVuv( ((uint8_t*)result.pointer)[i] );
              }
              break;
            case FFI_TYPE_SINT8:
              for(i=0; i<count; i++)
              {
                sv[i] = newSViv( ((int8_t*)result.pointer)[i] );
              }
              break;
            case FFI_TYPE_UINT16:
              for(i=0; i<count; i++)
              {
                sv[i] = newSVuv( ((uint16_t*)result.pointer)[i] );
              }
              break;
            case FFI_TYPE_SINT16:
              for(i=0; i<count; i++)
              {
                sv[i] = newSViv( ((int16_t*)result.pointer)[i] );
              }
              break;
            case FFI_TYPE_UINT32:
              for(i=0; i<count; i++)
              {
                sv[i] = newSVuv( ((uint32_t*)result.pointer)[i] );
              }
              break;
            case FFI_TYPE_SINT32:
              for(i=0; i<count; i++)
              {
                sv[i] = newSViv( ((int32_t*)result.pointer)[i] );
              }
              break;
            case FFI_TYPE_UINT64:
              for(i=0; i<count; i++)
              {
#ifdef HAVE_IV_IS_64
                sv[i] = newSVuv( ((uint64_t*)result.pointer)[i] );
#else
                sv[i] = newSVu64( ((uint64_t*)result.pointer)[i] );
#endif
              }
              break;
            case FFI_TYPE_SINT64:
              for(i=0; i<count; i++)
              {
#ifdef HAVE_IV_IS_64
                sv[i] = newSViv( ((int64_t*)result.pointer)[i] );
#else
                sv[i] = newSVi64( ((int64_t*)result.pointer)[i] );
#endif
              }
              break;
            case FFI_TYPE_FLOAT:
              for(i=0; i<count; i++)
              {
                sv[i] = newSVnv( ((float*)result.pointer)[i] );
              }
              break;
            case FFI_TYPE_DOUBLE:
              for(i=0; i<count; i++)
              {
                sv[i] = newSVnv( ((double*)result.pointer)[i] );
              }
              break;
            case FFI_TYPE_POINTER:
              for(i=0; i<count; i++)
              {
                if( ((void**)result.pointer)[i] == NULL)
                {
                  sv[i] = &PL_sv_undef;
                }
                else
                {
                  sv[i] = newSViv( PTR2IV( ((void**)result.pointer)[i] ));
                }
              }
              break;
#ifdef FFI_PL_PROBE_LONGDOUBLE
            case FFI_TYPE_LONGDOUBLE:
              for(i=0; i<count; i++)
              {
                sv[i] = newSV(0);
                ffi_pl_long_double_to_perl(sv[i], &((long double*)result.pointer)[i]);
              }
              break;
#endif
            default:
              warn("return type not supported");
              XSRETURN_EMPTY;
          }
          av = av_make(count, sv);
          Safefree(sv);
          ST(0) = newRV_inc((SV*)av);
          XSRETURN(1);
        }
      }
      else if(sv_derived_from(return_type, "FFI::Platypus::Type::CustomPerl"))
      {
        SV *ret_in=NULL, *ret_out;
        AV *av;
        SV **svp;
        STRLEN len;
        const char *name;
        ffi_type *ffi;
        svp = hv_fetch(pl_return_type->hv, "underlying_types", strlen("underlying_types"), 0);
	av = (AV *)SvRV(*svp);
	svp = av_fetch(av, 0, 0);
	if(sv_derived_from(*svp, "FFI::Platypus::Type::FFI"))
	  ffi = INT2PTR(ffi_type *, SvIV((SV*)SvRV(*svp)));
	else {
	  ffi = SV2ffi_pl_type(*svp)->ffi_type;
	}

        switch(ffi->type)
        {
          case FFI_TYPE_UINT8:
#ifdef FFI_PL_PROBE_BIGENDIAN
            ret_in = newSVuv(result.uint8_array[3]);
#else
            ret_in = newSVuv(result.uint8);
#endif
            break;
          case FFI_TYPE_SINT8:
#ifdef FFI_PL_PROBE_BIGENDIAN
            ret_in = newSViv(result.sint8_array[3]);
#else
            ret_in = newSViv(result.sint8);
#endif
            break;
          case FFI_TYPE_UINT16:
#ifdef FFI_PL_PROBE_BIGENDIAN
            ret_in = newSVuv(result.uint16_array[1]);
#else
            ret_in = newSVuv(result.uint16);
#endif
            break;
          case FFI_TYPE_SINT16:
#ifdef FFI_PL_PROBE_BIGENDIAN
            ret_in = newSViv(result.sint16_array[1]);
#else
            ret_in = newSViv(result.sint16);
#endif
            break;
          case FFI_TYPE_UINT32:
            ret_in = newSVuv(result.uint32);
            break;
          case FFI_TYPE_SINT32:
            ret_in = newSViv(result.sint32);
            break;
          case FFI_TYPE_UINT64:
#ifdef HAVE_IV_IS_64
            ret_in = newSVuv(result.uint64);
#else
            ret_in = newSVu64(result.uint64);
#endif
            break;
          case FFI_TYPE_SINT64:
#ifdef HAVE_IV_IS_64
            ret_in = newSViv(result.sint64);
#else
            ret_in = newSVi64(result.sint64);
#endif
            break;
          case FFI_TYPE_FLOAT:
            ret_in = newSVnv(result.xfloat);
            break;
          case FFI_TYPE_DOUBLE:
            ret_in = newSVnv(result.xdouble);
            break;
          case FFI_TYPE_POINTER:
            if(result.pointer != NULL)
              ret_in = newSViv(PTR2IV(result.pointer));
            break;
          default:
#ifndef HAVE_ALLOCA
            Safefree(arguments);
#endif
            warn("return type not supported");
            XSRETURN_EMPTY;
        }

	current_argv = arguments;

	{
	  HV *hv = (HV*)SvRV(return_type);
	  SV **svp;
	  SV *arg2 = NULL;
	  SV *native_to_perl_sv = NULL;

	  svp = hv_fetch(hv, "native_to_perl", strlen("native_to_perl"), 0);
	  if (svp) {
	    native_to_perl_sv = *svp;
	  }
	  ret_out = ffi_pl_custom_perl(
            native_to_perl_sv,
            ret_in != NULL ? ret_in : &PL_sv_undef,
            -1
	  );
	}

        current_argv = NULL;

#ifndef HAVE_ALLOCA
        Safefree(arguments);
#endif

        if(ret_in != NULL)
        {
          SvREFCNT_dec(ret_in);
        }

        if(ret_out == NULL)
        {
          XSRETURN_EMPTY;
        }
        else
        {
          ST(0) = sv_2mortal(ret_out);
          XSRETURN(1);
        }
    }
    else if(sv_derived_from(return_type, "FFI::Platypus::Type::ExoticFloat"))
    {
      switch(pl_return_type->ffi_type->type)
      {
#ifdef FFI_PL_PROBE_LONGDOUBLE
        case FFI_TYPE_LONGDOUBLE:
        {
          if(have_math_longdouble)
          {
            SV *sv;
            long double *ptr;
            Newx(ptr, 1, long double);
            *ptr = result.longdouble;
            sv = sv_newmortal();
            sv_setref_pv(sv, "Math::LongDouble", (void*)ptr);
            ST(0) = sv;
            XSRETURN(1);
          }
          else
          {
            XSRETURN_NV((double) result.longdouble);
          }
        }
#endif
      }
    }
    }

    warn("return type not supported");
    XSRETURN_EMPTY;

#undef EXTRA_ARGS
