#define PERL_NO_GET_CONTEXT /* see perlguts */
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
//#include "ppport.h"

/* exit with 0 if there is a perl context, 1 if there isn't */

void test(void *p)
{
  if(p==(void *)7)
    exit(1);
  else
    exit(0);
}

int main(void)
{
  dTHX;
  void (*t)(pTHX_ void *) = (void *)test;

  t(aTHX_ (void *)7);
}
