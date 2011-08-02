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

#include <sys/param.h>
#include <sys/types.h>
#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include <errno.h>
#include <ruby.h>

#include <ffi.h>
#include "rbffi.h"
#include "compat.h"

#include "Type.h"
#include "StructByValue.h"
#include "Struct.h"

#define FFI_ALIGN(v, a)  (((((size_t) (v))-1) | ((a)-1))+1)

static VALUE sbv_allocate(VALUE);
static VALUE sbv_initialize(VALUE, VALUE);
static void sbv_mark(StructByValue *);
static void sbv_free(StructByValue *);

VALUE rbffi_StructByValueClass = Qnil;

static VALUE
sbv_allocate(VALUE klass)
{
    StructByValue* sbv;

    VALUE obj = Data_Make_Struct(klass, StructByValue, sbv_mark, sbv_free, sbv);

    sbv->rbStructClass = Qnil;
    sbv->rbStructLayout = Qnil;
    sbv->base.nativeType = NATIVE_STRUCT;

    sbv->base.ffiType = xcalloc(1, sizeof(*sbv->base.ffiType));
    sbv->base.ffiType->size = 0;
    sbv->base.ffiType->alignment = 1;
    sbv->base.ffiType->type = FFI_TYPE_STRUCT;

    return obj;
}

static VALUE
sbv_initialize(VALUE self, VALUE rbStructClass)
{
    StructByValue* sbv = NULL;
    StructLayout* layout = NULL;
    VALUE rbLayout = Qnil;

    rbLayout = rb_cvar_get(rbStructClass, rb_intern("@layout"));
    if (!rb_obj_is_instance_of(rbLayout, rbffi_StructLayoutClass)) {
        rb_raise(rb_eTypeError, "wrong type in @layout cvar (expected FFI::StructLayout)");
    }

    Data_Get_Struct(rbLayout, StructLayout, layout);
    Data_Get_Struct(self, StructByValue, sbv);
    sbv->rbStructClass = rbStructClass;
    sbv->rbStructLayout = rbLayout;

    // We can just use everything from the ffi_type directly
    *sbv->base.ffiType = *layout->base.ffiType;
    
    return self;
}

static void
sbv_mark(StructByValue *sbv)
{
    rb_gc_mark(sbv->rbStructClass);
    rb_gc_mark(sbv->rbStructLayout);
}

static void
sbv_free(StructByValue *sbv)
{
    xfree(sbv->base.ffiType);
    xfree(sbv);
}


static VALUE
sbv_layout(VALUE self)
{
    StructByValue* sbv;

    Data_Get_Struct(self, StructByValue, sbv);
    return sbv->rbStructLayout;
}

static VALUE
sbv_struct_class(VALUE self)
{
    StructByValue* sbv;

    Data_Get_Struct(self, StructByValue, sbv);

    return sbv->rbStructClass;
}

void
rbffi_StructByValue_Init(VALUE moduleFFI)
{
    rbffi_StructByValueClass = rb_define_class_under(moduleFFI, "StructByValue", rbffi_TypeClass);
    rb_global_variable(&rbffi_StructByValueClass);
    rb_define_const(rbffi_TypeClass, "Struct", rbffi_StructByValueClass);

    rb_define_alloc_func(rbffi_StructByValueClass, sbv_allocate);
    rb_define_method(rbffi_StructByValueClass, "initialize", sbv_initialize, 1);
    rb_define_method(rbffi_StructByValueClass, "layout", sbv_layout, 0);
    rb_define_method(rbffi_StructByValueClass, "struct_class", sbv_struct_class, 0);
}

