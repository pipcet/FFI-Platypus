MODULE = FFI::Platypus PACKAGE = FFI::Platypus::Lazy::Function

SV *
attach_method_lazy_address()
  PREINIT:
    void _attach_method_lazy(pTHX_ void *self_ptr)
    {
      SV *hashref = self_ptr;
      SV **svp = hv_fetch((HV*)hashref, "body", strlen("body"), 0);
      if(!svp)
	croak("internal error in lazy Platypus code");
      void (*body)(pTHX_ void *) = INT2PTR(void (*)(pTHX_ void *), SvIV(*svp));

      svp = hv_fetch((HV*)hashref, "my_name", strlen("my_name"), 0);
      if(!svp)
	croak("internal error in lazy Platypus code");
      SV *my_name = *svp;

      body(aTHX_ newRV_noinc(self_ptr));

      /* at this point, we have been replaced in the other_methods
	 hash. All that's left to do is to call ourselves by name to
	 re-enter ffi_pl_method_call. Again, we don't touch the Perl
	 stack at all, so it will re-use our arguments for calling the
	 replacement function. */
      int count = call_pv(SvPV_nolen(my_name), G_SCALAR);
    }
  CODE:
    RETVAL = newSViv(PTR2IV(_attach_method_lazy));
  OUTPUT:
    RETVAL
