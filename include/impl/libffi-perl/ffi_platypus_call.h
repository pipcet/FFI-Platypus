#ifdef FFI_PL_PROBE_RUNTIMESIZEDARRAYS
    void *argument_pointers[self->ffi_cif.nargs];
    ffi_pl_ffiperl_argument argument_slots[self->ffi_cif.nargs];
#else
    Newx(argument_pointers, self->ffi_cif.nargs, void *);
    Newx(argument_slots, self->ffi_cif.nargs, ffi_pl_ffiperl_argument);
#endif
    arguments.pointers = (ffi_pl_ffiperl_argument **)argument_pointers;
    current_argv = &arguments;

    arguments.count = self->ffi_cif.nargs;

    for(i=0; i<self->ffi_cif.nargs; i++)
    {
      argument_pointers[i] = &argument_slots[i];
    }

    /*
     * ARGUMENT IN
     */

    for(i=0, perl_type_index=0, perl_arg_index=EXTRA_ARGS; i < self->ffi_cif.nargs; perl_type_index++)
    {
      SV *type_sv = self->argument_getters[perl_type_index].sv;
      int perl_args = self->argument_getters[perl_type_index].perl_args;
      int native_args = self->argument_getters[perl_type_index].native_args;
      int count;

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

      count = self->argument_getters[perl_type_index].perl_to_native(&arguments, i, type_sv, arg, &freeme);
      SPAGAIN;

      i += count;
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
      &arguments.pointers[i],
      arguments.pointers[i]
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
      fprintf(stderr, "%016llx", ffi_pl_ffiperl_arguments_get_uint64(arguments, i));
    }
    fprintf(stderr, "\n");
  }
  fprintf(stderr, "# === ===\n");
  fflush(stderr);
#endif

  current_argv = NULL;

  ffi_call(&self->ffi_cif, self->address, &result, (void **)arguments.pointers);

  /*
   * ARGUMENT OUT
   */

  current_argv = &arguments;

  if(self->any_post)
  {
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
	count = self->argument_getters[perl_type_index].perl_to_native_post(&arguments, i, type_sv, arg, &freeme);
	SPAGAIN;

	SvREFCNT_dec(arg);

	i -= count;
      } else {
	perl_arg_index--;
	i--;
      }
    }
  }

  /*
   * RETURN VALUE
   */

  SV *perl_return = NULL;

  if(self->native_to_perl)
  {
    perl_return = self->native_to_perl(&result, self->return_type);
    SPAGAIN;
  }

  if(freeme)
  {
    SvREFCNT_dec(freeme);
  }

#ifndef FFI_PL_PROBE_RUNTIMESIZEDARRAYS
  Safefree(argument_pointers);
  Safefree(argument_slots);
#endif
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
