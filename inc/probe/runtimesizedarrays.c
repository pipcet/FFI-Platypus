#include "ffi_platypus.h"
#include <string.h>

/* This file checks for three things: that we have runtime-sized
   arrays, that we can declare them after statements, and that GCC's
   __attribute__((aligned)) is supported. */

int
main(int argc, char *argv[])
{
  argc++;

  void *array[argc] __attribute__((aligned));

  memcmp(array, array, argc*sizeof *array);

  return 0;
}
