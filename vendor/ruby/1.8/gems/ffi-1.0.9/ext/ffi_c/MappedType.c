/*
 * Copyright (c) 2010, Wayne Meissner
 *
 * All rights reserved.
 *
 * This file is part of ruby-ffi.
 *
 * This code is free software: you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License version 3 only, as
 * published by the Free Software Foundation.
 *
 * This code is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License
 * version 3 for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * version 3 along with this work.  If not, see <http://www.gnu.org/licenses/>.
 */

#include <ruby.h>

#include <ffi.h>
#include "rbffi.h"

#include "Type.h"
#include "MappedType.h"


static VALUE mapped_allocate(VALUE);
static VALUE mapped_initialize(VALUE, VALUE);
static void mapped_mark(MappedType *);
static ID id_native_type, id_to_native, id_from_native;

VALUE rbffi_MappedTypeClass = Qnil;

static VALUE
mapped_allocate(VALUE klass)
{
    MappedType* m;

    VALUE obj = Data_Make_Struct(klass, MappedType, mapped_mark, -1, m);

    m->rbConverter = Qnil;
    m->rbType = Qnil;
    m->type = NULL;
    m->base.nativeType = NATIVE_MAPPED;
    m->base.ffiType = &ffi_type_void;
    
    return obj;
}

static VALUE
mapped_initialize(VALUE self, VALUE rbConverter)
{
    MappedType* m = NULL;
    Type* t = NULL;
    
    if (!rb_respond_to(rbConverter, id_native_type)) {
        rb_raise(rb_eNoMethodError, "native_type method not implemented");
    }

    if (!rb_respond_to(rbConverter, id_to_native)) {
        rb_raise(rb_eNoMethodError, "to_native method not implemented");
    }

    if (!rb_respond_to(rbConverter, id_from_native)) {
        rb_raise(rb_eNoMethodError, "from_native method not implemented");
    }
    
    Data_Get_Struct(self, MappedType, m);
    m->rbType = rb_funcall2(rbConverter, id_native_type, 0, NULL);
    if (!(rb_obj_is_kind_of(m->rbType, rbffi_TypeClass))) {
        rb_raise(rb_eTypeError, "native_type did not return instance of FFI::Type");
    }

    m->rbConverter = rbConverter;
    Data_Get_Struct(m->rbType, Type, m->type);
    m->base.ffiType = m->type->ffiType;
    
    return self;
}

static void
mapped_mark(MappedType* m)
{
    rb_gc_mark(m->rbType);
    rb_gc_mark(m->rbConverter);
}

static VALUE
mapped_native_type(VALUE self)
{
    MappedType*m = NULL;
    Data_Get_Struct(self, MappedType, m);

    return m->rbType;
}

static VALUE
mapped_to_native(int argc, VALUE* argv, VALUE self)
{
    MappedType*m = NULL;
    
    Data_Get_Struct(self, MappedType, m);
    
    return rb_funcall2(m->rbConverter, id_to_native, argc, argv);
}

static VALUE
mapped_from_native(int argc, VALUE* argv, VALUE self)
{
    MappedType*m = NULL;
    
    Data_Get_Struct(self, MappedType, m);

    return rb_funcall2(m->rbConverter, id_from_native, argc, argv);
}

void
rbffi_MappedType_Init(VALUE moduleFFI)
{
    
    rbffi_MappedTypeClass = rb_define_class_under(rbffi_TypeClass, "Mapped", rbffi_TypeClass);
    
    rb_global_variable(&rbffi_MappedTypeClass);

    id_native_type = rb_intern("native_type");
    id_to_native = rb_intern("to_native");
    id_from_native = rb_intern("from_native");

    rb_define_alloc_func(rbffi_MappedTypeClass, mapped_allocate);
    rb_define_method(rbffi_MappedTypeClass, "initialize", mapped_initialize, 1);
    rb_define_method(rbffi_MappedTypeClass, "type", mapped_native_type, 0);
    rb_define_method(rbffi_MappedTypeClass, "native_type", mapped_native_type, 0);
    rb_define_method(rbffi_MappedTypeClass, "to_native", mapped_to_native, -1);
    rb_define_method(rbffi_MappedTypeClass, "from_native", mapped_from_native, -1);
}

