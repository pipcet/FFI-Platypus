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

      count = self->argument_getters[perl_type_index].perl_to_native(arguments, i, type_sv, arg, argument_pointers, &freeme);

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
    if(self->argument_getters[perl_type_index].perl_to_native_post)
    {
      SV *type_sv = self->argument_getters[perl_type_index].sv;
      int perl_args = self->argument_getters[perl_type_index].perl_args;
      int native_args = self->argument_getters[perl_type_index].native_args;
      int count;

      if(perl_args == 1)
      {
	arg = perl_arg_index < items ? SvREFCNT_inc(ST(perl_arg_index)) : &PL_sv_undef;
	perl_arg_index--;
      }
      else
      {
	arg = (SV*)newAV();
	av_unshift((AV *)arg, perl_args);
	for(n=0; n<perl_args; n++)
	{
	  /* XXX isn't this reversed for the perl_args > 1 case? We're
	     not testing that one yet ... */
	  av_store((AV *)arg, n, perl_arg_index < items ? SvREFCNT_inc(ST(perl_arg_index)) : &PL_sv_undef);
	  perl_arg_index--;
	}
      }
      count = self->argument_getters[perl_type_index].perl_to_native_post(arguments, i, type_sv, arg, argument_pointers, &freeme);

      SvREFCNT_dec(arg);

      i -= count;
    } else {
      perl_arg_index--;
      i--;
    }

  }

#ifndef HAVE_ALLOCA
  if(!sv_derived_from(self->return_type, "FFI::Platypus::Type::CustomPerl"))
    Safefree(arguments);
#endif
  if(!sv_derived_from(self->return_type, "FFI::Platypus::Type::CustomPerl"))
    current_argv = NULL;

 
  /*
   * RETURN VALUE
   */

  SV *perl_return = self->native_to_perl(&result, self->return_type);

  if(freeme)
  {
    SvREFCNT_dec(freeme);
  }

#ifndef HAVE_ALLOCA
  if(sv_derived_from(self->return_type, "FFI::Platypus::Type::CustomPerl"))
    Safefree(arguments);
#endif
  if(sv_derived_from(self->return_type, "FFI::Platypus::Type::CustomPerl"))
    current_argv = NULL;

  if(perl_return == NULL)
  {
    XSRETURN_EMPTY;
  }
  else if(SvTYPE(perl_return) == SVt_PVAV)
  {
    int n = av_len((AV*)perl_return)+1;
    int i;

    for(i=0; i<n; i++)
    {
      SV **svp;
      svp = av_fetch((AV*)perl_return, i, 0);
      XPUSHs(*svp);
    }
    
    XSRETURN(n);
  }
  else
  {
    ST(0) = perl_return;
    XSRETURN(1);
  }

#undef EXTRA_ARGS
