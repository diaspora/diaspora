#include <typhoeus_form.h>

VALUE cTyphoeusForm;

static void dealloc(CurlForm *curl_form) {
  curl_formfree(curl_form->first);
  free(curl_form);
}

static VALUE formadd_file(VALUE self,
                         VALUE name,
                         VALUE filename,
                         VALUE content_type,
                         VALUE path) {
  CurlForm *curl_form;
  Data_Get_Struct(self, CurlForm, curl_form);

  return INT2NUM((long) curl_formadd(&curl_form->first, &curl_form->last,
    CURLFORM_COPYNAME, RSTRING_PTR(name),
    CURLFORM_NAMELENGTH, (long)RSTRING_LEN(name),
    CURLFORM_FILENAME, RSTRING_PTR(filename),
    CURLFORM_CONTENTTYPE, RSTRING_PTR(content_type),
    CURLFORM_FILE, RSTRING_PTR(path),
    CURLFORM_END
  ));
}

static VALUE formadd_param(VALUE self, VALUE name, VALUE value) {
  CurlForm *curl_form;
  Data_Get_Struct(self, CurlForm, curl_form);

  return INT2NUM((long)curl_formadd(&curl_form->first, &curl_form->last,
    CURLFORM_COPYNAME, RSTRING_PTR(name),
    CURLFORM_NAMELENGTH, (long)RSTRING_LEN(name),
    CURLFORM_COPYCONTENTS, RSTRING_PTR(value),
    CURLFORM_CONTENTSLENGTH, (long)RSTRING_LEN(value),
    CURLFORM_END
  ));
}

static VALUE new(int argc, VALUE *argv, VALUE klass) {
  CurlForm *curl_form = ALLOC(CurlForm);
  curl_form->first = NULL;
  curl_form->last = NULL;

  VALUE form = Data_Wrap_Struct(cTyphoeusForm, 0, dealloc, curl_form);

  rb_obj_call_init(form, argc, argv);

  return form;
}

void init_typhoeus_form() {
  VALUE klass = cTyphoeusForm = rb_define_class_under(mTyphoeus, "Form", rb_cObject);

  rb_define_singleton_method(klass, "new", new, -1);
  rb_define_private_method(klass, "formadd_file", formadd_file, 4);
  rb_define_private_method(klass, "formadd_param", formadd_param, 2);
}
