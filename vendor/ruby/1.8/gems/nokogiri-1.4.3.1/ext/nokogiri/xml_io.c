#include <xml_io.h>

static ID id_read, id_write;

int io_read_callback(void * ctx, char * buffer, int len) {
  VALUE io = (VALUE)ctx;
  VALUE string = rb_funcall(io, id_read, 1, INT2NUM(len));

  if(NIL_P(string)) return 0;

  memcpy(buffer, StringValuePtr(string), (unsigned int)RSTRING_LEN(string));

  return (int)RSTRING_LEN(string);
}

int io_write_callback(void * ctx, char * buffer, int len) {
  VALUE io = (VALUE)ctx;
  VALUE string = rb_str_new(buffer, len);

  rb_funcall(io, id_write, 1, string);
  return len;
}

int io_close_callback(void * ctx) {
  return 0;
}

void init_nokogiri_io() {
  id_read = rb_intern("read");
  id_write = rb_intern("write");
}
