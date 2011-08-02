
#include <ruby.h>

#include <ffi.h>
#include "rbffi.h"

#include "Type.h"
#include "MappedType.h"


VALUE rbffi_DataConverterClass = Qnil;
static ID id_native_type_ivar;

static VALUE
conv_native_type(int argc, VALUE* argv, VALUE self)
{
    if (argc == 0) {
        if (!rb_ivar_defined(self, id_native_type_ivar)) {
            rb_raise(rb_eNotImpError, "native_type method not overridden and no native_type set");
        }

        return rb_ivar_get(self, id_native_type_ivar);

    } else if (argc == 1) {
        VALUE type = rbffi_Type_Find(argv[0]);

        rb_ivar_set(self, id_native_type_ivar, type);

        return type;

    } else {
        rb_raise(rb_eArgError, "incorrect arguments");
    }
}

static VALUE
conv_to_native(VALUE self, VALUE value, VALUE ctx)
{
    return value;
}

static VALUE
conv_from_native(VALUE self, VALUE value, VALUE ctx)
{
    return value;
}



void
rbffi_DataConverter_Init(VALUE moduleFFI)
{
    rbffi_DataConverterClass = rb_define_module_under(moduleFFI, "DataConverter");

    rb_define_method(rbffi_DataConverterClass, "native_type", conv_native_type, -1);
    rb_define_method(rbffi_DataConverterClass, "to_native", conv_to_native, 2);
    rb_define_method(rbffi_DataConverterClass, "from_native", conv_from_native, 2);

    id_native_type_ivar = rb_intern("@native_type");
}


