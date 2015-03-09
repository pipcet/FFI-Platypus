#define PREFETCH1 (void)
#define PREFETCH2 (void)
#define PREFETCH3 __builtin_prefetch
#define PREFETCH4 (void)
#define PREFETCH5 (void)
#define PREFETCH6 (void)
#define PREFETCH7 (void)
#define PREFETCH8 (void)
#define PREFETCH9 __builtin_prefetch
#define PREFETCH10 __builtin_prefetch

    PREFETCH10(self);

#ifdef FFI_PL_PROBE_RUNTIMESIZEDARRAYS
    void *argument_pointers[self->ffi_cif.nargs];
    ffi_pl_argument argument_slots[self->ffi_cif.nargs+self->stack_args];
#else
    Newx(argument_pointers, self->ffi_cif.nargs, void *);
    Newx(argument_slots, self->ffi_cif.nargs+self->stack_args, ffi_pl_argument);
#endif
    arguments.pointers = (ffi_pl_argument **)argument_pointers;
    current_argv = &arguments;

    arguments.count = self->ffi_cif.nargs;

    int pointer_index;
    int slot_index;

    for(pointer_index=0, slot_index=0, perl_type_index=0; pointer_index<__builtin_expect(self->ffi_cif.nargs,4); perl_type_index++)
    {
      int j;

      for(j=0; j<__builtin_expect(self->argument_getters[perl_type_index].native_args,1); j++)
      {
	argument_pointers[pointer_index++] = &argument_slots[slot_index++];
      }

      slot_index += __builtin_expect(self->argument_getters[perl_type_index].stack_args, 0);
      PREFETCH1(self->argument_getters[perl_type_index].perl_to_native);
      PREFETCH2(self->argument_getters[perl_type_index].extra_data);
      PREFETCH3(ST(perl_type_index));
      //__builtin_prefetch(self->argument_getters[perl_type_index].perl_to_native);
    }

    PREFETCH6(self->ffi_cif);
    PREFETCH7(TARG);

    /*
     * ARGUMENT IN
     */

    for(i=0, perl_type_index=0, perl_arg_index=EXTRA_ARGS; i < __builtin_expect(self->ffi_cif.nargs, 4); perl_type_index++)
    {
      SV *type_sv = self->argument_getters[perl_type_index].sv;
      void *extra_data = self->argument_getters[perl_type_index].extra_data;
      int perl_args = self->argument_getters[perl_type_index].perl_args;
      int native_args = self->argument_getters[perl_type_index].native_args;
      int count;

      PREFETCH4(self->argument_getters[perl_type_index].perl_to_native);
      PREFETCH5(self->argument_getters[perl_type_index].extra_data);

      __builtin_prefetch(self->argument_getters[perl_type_index].perl_to_native);
      if(__builtin_expect(perl_args, 1) == 1)
      {
        arg = __builtin_expect(perl_arg_index < items, 1) ? ST(perl_arg_index) : &PL_sv_undef;
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

      __builtin_expect(count = self->argument_getters[perl_type_index].perl_to_native(&arguments, i, type_sv, extra_data, arg, &freeme), 1);
      SPAGAIN;
      i += __builtin_expect(count, 1);
    }

    PREFETCH8(self->ffi_cif);
    PREFETCH9(TARG);

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
      fprintf(stderr, "%016llx", ffi_pl_arguments_get_uint64(arguments, i));
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

  if(__builtin_expect(self->any_post, 0))
  {
    for(i=self->ffi_cif.nargs,perl_arg_index--,perl_type_index--; i > 0; perl_type_index--)
    {
      if(self->argument_getters[perl_type_index].perl_to_native_post)
      {
	SV *type_sv = self->argument_getters[perl_type_index].sv;
	void *extra_data = self->argument_getters[perl_type_index].extra_data;
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
	count = self->argument_getters[perl_type_index].perl_to_native_post(&arguments, i, type_sv, extra_data, arg, &freeme);
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

  if(__builtin_expect(self->native_to_perl == ffi_pl_rtypes_native_to_perl_ffi_sint32, 1))
  {
    sv_setiv(TARG, (IV)result.sint32);
    XSprePUSH;
    PUSHTARG;
    XSRETURN(1);
  }
  else if(self->native_to_perl)
  {
    perl_return = self->native_to_perl(TARG, &result, self->return_type, self->extra_data);
    SPAGAIN;
  }

  if(__builtin_expect(!!freeme, 0))
  {
    SvREFCNT_dec(freeme);
  }

#ifndef FFI_PL_PROBE_RUNTIMESIZEDARRAYS
  Safefree(argument_pointers);
  Safefree(argument_slots);
#endif
  current_argv = NULL;


  if(__builtin_expect(perl_return == TARG, 1))
  {
    XSprePUSH;
    PUSHTARG;
    XSRETURN(1);
  }

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
