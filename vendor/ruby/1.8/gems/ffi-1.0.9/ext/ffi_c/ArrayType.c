/*
 * Copyright (c) 2009, Wayne Meissner
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
#include "ArrayType.h"

static VALUE array_type_s_allocate(VALUE klass);
static VALUE array_type_initialize(VALUE self, VALUE rbComponentType, VALUE rbLength);
static void array_type_mark(ArrayType *);
static void array_type_free(ArrayType *);

VALUE rbffi_ArrayTypeClass = Qnil;

static VALUE
array_type_s_allocate(VALUE klass)
{
    ArrayType* array;
    VALUE obj;

    obj = Data_Make_Struct(klass, ArrayType, array_type_mark, array_type_free, array);

    array->base.nativeType = NATIVE_ARRAY;
    array->base.ffiType = xcalloc(1, sizeof(*array->base.ffiType));
    array->base.ffiType->type = FFI_TYPE_STRUCT;
    array->base.ffiType->size = 0;
    array->base.ffiType->alignment = 0;
    array->rbComponentType = Qnil;

    return obj;
}

static void
array_type_mark(ArrayType *array)
{
    rb_gc_mark(array->rbComponentType);
}

static void
array_type_free(ArrayType *array)
{
    xfree(array->base.ffiType);
    xfree(array->ffiTypes);
    xfree(array);
}


static VALUE
array_type_initialize(VALUE self, VALUE rbComponentType, VALUE rbLength)
{
    ArrayType* array;
    int i;

    Data_Get_Struct(self, ArrayType, array);

    array->length = NUM2UINT(rbLength);
    array->rbComponentType = rbComponentType;
    Data_Get_Struct(rbComponentType, Type, array->componentType);
    
    array->ffiTypes = xcalloc(array->length + 1, sizeof(*array->ffiTypes));
    array->base.ffiType->elements = array->ffiTypes;
    array->base.ffiType->size = array->componentType->ffiType->size * array->length;
    array->base.ffiType->alignment = array->componentType->ffiType->alignment;

    for (i = 0; i < array->length; ++i) {
        array->ffiTypes[i] = array->componentType->ffiType;
    }

    return self;
}

static VALUE
array_type_length(VALUE self)
{
    ArrayType* array;

    Data_Get_Struct(self, ArrayType, array);

    return UINT2NUM(array->length);
}

static VALUE
array_type_element_type(VALUE self)
{
    ArrayType* array;

    Data_Get_Struct(self, ArrayType, array);

    return array->rbComponentType;
}

void
rbffi_ArrayType_Init(VALUE moduleFFI)
{
    rbffi_ArrayTypeClass = rb_define_class_under(moduleFFI, "ArrayType", rbffi_TypeClass);
    rb_global_variable(&rbffi_ArrayTypeClass);
    rb_define_const(rbffi_TypeClass, "Array", rbffi_ArrayTypeClass);

    rb_define_alloc_func(rbffi_ArrayTypeClass, array_type_s_allocate);
    rb_define_method(rbffi_ArrayTypeClass, "initialize", array_type_initialize, 2);
    rb_define_method(rbffi_ArrayTypeClass, "length", array_type_length, 0);
    rb_define_method(rbffi_ArrayTypeClass, "elem_type", array_type_element_type, 0);
}

