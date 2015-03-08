#include <string.h>
#include <stdio.h>

const char *split_buffer(const char *(*splitter)(void *, size_t), void *buffer, size_t size)
{
  fprintf(stderr, "buffer is %s\n", buffer);
  const char *ret = splitter(buffer, size);
  fprintf(stderr, "ret is %s\n", ret);
  return splitter(buffer, size);
}
