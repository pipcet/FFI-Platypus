#include <stdlib.h>
#include <stdio.h>

struct object {
  int x;
  const char *y;
};

struct object *object_new(int x, const char *y)
{
  struct object *self = malloc(sizeof *self);

  if(!self)
    return NULL;

  self->x = x;
  self->y = y;

  return self;
}

int object_method(struct object *self, int index)
{
  return self->x ^ self->y[index];
}

void object_destroy(struct object *self)
{
  fprintf(stderr, "object_destroy called\n");
  free(self);
}
