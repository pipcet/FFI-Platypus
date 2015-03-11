MODULE = FFI::Platypus PACKAGE = FFI::Platypus::RTypes::ClosureData

void
DESTROY(self)
    ffi_pl_rtypes_closure *self
  CODE:
    /*
    if(PL_dirty)
      fprintf(stderr, "global DESTROY\n");
    else
      fprintf(stderr, "local  DESTROY\n");
    fflush(stderr);
    */
    ffi_closure_free(self->ffi_closure);
    Safefree(self);
