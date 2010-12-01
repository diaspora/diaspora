/*
 * Copyright (c) 2008, 2009, Wayne Meissner
 * Copyright (c) 2009, Luc Heinrich <luc@honk-honk.com>
 *
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * * Redistributions of source code must retain the above copyright notice, this
 *   list of conditions and the following disclaimer.
 * * Redistributions in binary form must reproduce the above copyright notice
 *   this list of conditions and the following disclaimer in the documentation
 *   and/or other materials provided with the distribution.
 * * The name of the author or authors may not be used to endorse or promote
 *   products derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#include <sys/types.h>

#include "Function.h"
#include <sys/param.h>
#include <stdint.h>
#include <stdbool.h>
#include <ruby.h>
#include "rbffi.h"
#include "compat.h"
#include "AbstractMemory.h"
#include "Pointer.h"
#include "MemoryPointer.h"
#include "Function.h"
#include "Types.h"
#include "Struct.h"
#include "StructByValue.h"
#include "ArrayType.h"

#define FFI_ALIGN(v, a)  (((((size_t) (v))-1) | ((a)-1))+1)

static void struct_layout_mark(StructLayout *);
static void struct_layout_free(StructLayout *);
static void struct_field_mark(StructField* );

VALUE rbffi_StructLayoutFieldClass = Qnil;
VALUE rbffi_StructLayoutFunctionFieldClass = Qnil, rbffi_StructLayoutArrayFieldClass = Qnil;

VALUE rbffi_StructLayoutClass = Qnil;


static VALUE
struct_field_allocate(VALUE klass)
{
    StructField* field;
    VALUE obj;

    obj = Data_Make_Struct(klass, StructField, struct_field_mark, -1, field);
    field->rbType = Qnil;
    field->rbName = Qnil;

    return obj;
}

static void
struct_field_mark(StructField* f)
{
    rb_gc_mark(f->rbType);
    rb_gc_mark(f->rbName);
}

static VALUE
struct_field_initialize(int argc, VALUE* argv, VALUE self)
{
    VALUE rbOffset = Qnil, rbName = Qnil, rbType = Qnil;
    StructField* field;
    int nargs;

    Data_Get_Struct(self, StructField, field);

    nargs = rb_scan_args(argc, argv, "3", &rbName, &rbOffset, &rbType);

    if (TYPE(rbName) != T_SYMBOL && TYPE(rbName) != T_STRING) {
        rb_raise(rb_eTypeError, "wrong argument type %s (expected Symbol/String)",
                rb_obj_classname(rbName));
    }

    Check_Type(rbOffset, T_FIXNUM);

    if (!rb_obj_is_kind_of(rbType, rbffi_TypeClass)) {
        rb_raise(rb_eTypeError, "wrong argument type %s (expected FFI::Type)",
                rb_obj_classname(rbType));
    }

    field->offset = NUM2UINT(rbOffset);
    field->rbName = (TYPE(rbName) == T_SYMBOL) ? rbName : rb_str_intern(rbName);
    field->rbType = rbType;
    Data_Get_Struct(field->rbType, Type, field->type);
    field->memoryOp = get_memory_op(field->type);

    return self;
}

static VALUE
struct_field_offset(VALUE self)
{
    StructField* field;
    Data_Get_Struct(self, StructField, field);
    return UINT2NUM(field->offset);
}

static VALUE
struct_field_size(VALUE self)
{
    StructField* field;
    Data_Get_Struct(self, StructField, field);
    return UINT2NUM(field->type->ffiType->size);
}

static VALUE
struct_field_alignment(VALUE self)
{
    StructField* field;
    Data_Get_Struct(self, StructField, field);
    return UINT2NUM(field->type->ffiType->alignment);
}

static VALUE
struct_field_type(VALUE self)
{
    StructField* field;
    Data_Get_Struct(self, StructField, field);

    return field->rbType;
}

static VALUE
struct_field_name(VALUE self)
{
    StructField* field;
    Data_Get_Struct(self, StructField, field);
    return field->rbName;
}

static VALUE
struct_field_get(VALUE self, VALUE pointer)
{
    StructField* f;

    Data_Get_Struct(self, StructField, f);
    if (f->memoryOp == NULL) {
        rb_raise(rb_eArgError, "get not supported for %s", rb_obj_classname(f->rbType));
        return Qnil;
    }

    return (*f->memoryOp->get)(MEMORY(pointer), f->offset);
}

static VALUE
struct_field_put(VALUE self, VALUE pointer, VALUE value)
{
    StructField* f;
    
    Data_Get_Struct(self, StructField, f);
    if (f->memoryOp == NULL) {
        rb_raise(rb_eArgError, "put not supported for %s", rb_obj_classname(f->rbType));
        return self;
    }

    (*f->memoryOp->put)(MEMORY(pointer), f->offset, value);

    return self;
}

static VALUE
function_field_get(VALUE self, VALUE pointer)
{
    StructField* f;
    
    Data_Get_Struct(self, StructField, f);

    return rbffi_Function_NewInstance(f->rbType, (*rbffi_AbstractMemoryOps.pointer->get)(MEMORY(pointer), f->offset));
}

static VALUE
function_field_put(VALUE self, VALUE pointer, VALUE proc)
{
    StructField* f;
    VALUE value = Qnil;

    Data_Get_Struct(self, StructField, f);

    if (NIL_P(proc) || rb_obj_is_kind_of(proc, rbffi_FunctionClass)) {
        value = proc;
    } else if (rb_obj_is_kind_of(proc, rb_cProc) || rb_respond_to(proc, rb_intern("call"))) {
        value = rbffi_Function_ForProc(f->rbType, proc);
    } else {
        rb_raise(rb_eTypeError, "wrong type (expected Proc or Function)");
    }

    (*rbffi_AbstractMemoryOps.pointer->put)(MEMORY(pointer), f->offset, value);

    return self;
}

static inline bool
isCharArray(ArrayType* arrayType)
{
    return arrayType->componentType->nativeType == NATIVE_INT8
            || arrayType->componentType->nativeType == NATIVE_UINT8;
}

static VALUE
array_field_get(VALUE self, VALUE pointer)
{
    StructField* f;
    ArrayType* array;
    VALUE argv[2];

    Data_Get_Struct(self, StructField, f);
    Data_Get_Struct(f->rbType, ArrayType, array);

    argv[0] = pointer;
    argv[1] = self;

    return rb_class_new_instance(2, argv, isCharArray(array)
            ? rbffi_StructLayoutCharArrayClass : rbffi_StructInlineArrayClass);
}

static VALUE
array_field_put(VALUE self, VALUE pointer, VALUE value)
{
    StructField* f;
    ArrayType* array;
    

    Data_Get_Struct(self, StructField, f);
    Data_Get_Struct(f->rbType, ArrayType, array);
    
    if (isCharArray(array) && rb_obj_is_instance_of(value, rb_cString)) {
        VALUE argv[2];

        argv[0] = INT2FIX(f->offset);
        argv[1] = value;

        rb_funcall2(pointer, rb_intern("put_string"), 2, argv);

    } else {
#ifdef notyet
        MemoryOp* op;
        int count = RARRAY_LEN(value);
        int i;
        AbstractMemory* memory = MEMORY(pointer);

        if (count > array->length) {
            rb_raise(rb_eIndexError, "array too large");
        }

        // clear the contents in case of a short write
        checkWrite(memory);
        checkBounds(memory, f->offset, f->type->ffiType->size);
        if (count < array->length) {
            memset(memory->address + f->offset + (count * array->componentType->ffiType->size),
                    0, (array->length - count) * array->componentType->ffiType->size);
        }

        // now copy each element in
        if ((op = get_memory_op(array->componentType)) != NULL) {

            for (i = 0; i < count; ++i) {
                (*op->put)(memory, f->offset + (i * array->componentType->ffiType->size), rb_ary_entry(value, i));
            }

        } else if (array->componentType->nativeType == NATIVE_STRUCT) {

            for (i = 0; i < count; ++i) {
                VALUE entry = rb_ary_entry(value, i);
                Struct* s;

                if (!rb_obj_is_kind_of(entry, rbffi_StructClass)) {
                    rb_raise(rb_eTypeError, "array element not an instance of FFI::Struct");
                    break;
                }

                Data_Get_Struct(entry, Struct, s);
                checkRead(s->pointer);
                checkBounds(s->pointer, 0, array->componentType->ffiType->size);

                memcpy(memory->address + f->offset + (i * array->componentType->ffiType->size),
                        s->pointer->address, array->componentType->ffiType->size);
            }

        } else {
            rb_raise(rb_eNotImpError, "put not supported for arrays of type %s", rb_obj_classname(array->rbComponentType));
        }
#else
        rb_raise(rb_eNotImpError, "cannot set array field");
#endif
    }

    return value;
}


static VALUE
struct_layout_allocate(VALUE klass)
{
    StructLayout* layout;
    VALUE obj;

    obj = Data_Make_Struct(klass, StructLayout, struct_layout_mark, struct_layout_free, layout);
    layout->rbFieldMap = Qnil;
    layout->rbFieldNames = Qnil;
    layout->rbFields = Qnil;
    layout->base.ffiType = xcalloc(1, sizeof(*layout->base.ffiType));
    layout->base.ffiType->size = 0;
    layout->base.ffiType->alignment = 0;
    layout->base.ffiType->type = FFI_TYPE_STRUCT;

    return obj;
}

static VALUE
struct_layout_initialize(VALUE self, VALUE field_names, VALUE fields, VALUE size, VALUE align)
{
    StructLayout* layout;
    ffi_type* ltype;
    int i;

    Data_Get_Struct(self, StructLayout, layout);
    layout->rbFieldMap = rb_hash_new();
    layout->rbFieldNames = rb_ary_dup(field_names);
    layout->size = NUM2INT(size);
    layout->align = NUM2INT(align);
    layout->fieldCount = RARRAY_LEN(field_names);
    layout->fields = xcalloc(layout->fieldCount, sizeof(StructField *));
    layout->ffiTypes = xcalloc(layout->fieldCount + 1, sizeof(ffi_type *));
    layout->rbFields = rb_ary_new2(layout->fieldCount);
    layout->base.ffiType->elements = layout->ffiTypes;
    layout->base.ffiType->size = 0;
    layout->base.ffiType->alignment = 1;

    ltype = layout->base.ffiType;
    for (i = 0; i < (int) layout->fieldCount; ++i) {
        VALUE rbName = rb_ary_entry(field_names, i);
        VALUE rbField = rb_hash_aref(fields, rbName);
        StructField* field;
        ffi_type* ftype;


        if (!rb_obj_is_kind_of(rbField, rbffi_StructLayoutFieldClass)) {
            rb_raise(rb_eTypeError, "wrong type for field %d.", i);
        }

        Data_Get_Struct(rbField, StructField, field = layout->fields[i]);

        if (field->type == NULL || field->type->ffiType == NULL) {
            rb_raise(rb_eRuntimeError, "type of field %d not supported", i);
        }

        ftype = field->type->ffiType;
        if (ftype->size == 0) {
            rb_raise(rb_eTypeError, "type of field %d has zero size", i);
        }

        rb_hash_aset(layout->rbFieldMap, rbName, rbField);
        layout->ffiTypes[i] = ftype;
        rb_ary_push(layout->rbFields, rbField);
        ltype->size = MAX(ltype->size, field->offset + ftype->size);
        ltype->alignment = MAX(ltype->alignment, ftype->alignment);
    }

    if (ltype->size == 0) {
        rb_raise(rb_eRuntimeError, "Struct size is zero");
    }

    // Include tail padding
    ltype->size = FFI_ALIGN(ltype->size, ltype->alignment);

    return self;
}

static VALUE
struct_layout_aref(VALUE self, VALUE field)
{
    StructLayout* layout;

    Data_Get_Struct(self, StructLayout, layout);

    return rb_hash_aref(layout->rbFieldMap, field);
}

static VALUE
struct_layout_fields(VALUE self)
{
    StructLayout* layout;

    Data_Get_Struct(self, StructLayout, layout);

    return rb_ary_dup(layout->rbFields);
}

static VALUE
struct_layout_members(VALUE self)
{
    StructLayout* layout;

    Data_Get_Struct(self, StructLayout, layout);

    return rb_ary_dup(layout->rbFieldNames);
}

static VALUE
struct_layout_to_a(VALUE self)
{
    StructLayout* layout;

    Data_Get_Struct(self, StructLayout, layout);

    return rb_ary_dup(layout->rbFields);
}

static void
struct_layout_mark(StructLayout *layout)
{
    rb_gc_mark(layout->rbFieldMap);
    rb_gc_mark(layout->rbFieldNames);
    rb_gc_mark(layout->rbFields);
}

static void
struct_layout_free(StructLayout *layout)
{
    xfree(layout->ffiTypes);
    xfree(layout->base.ffiType);
    xfree(layout->fields);
    xfree(layout);
}


void
rbffi_StructLayout_Init(VALUE moduleFFI)
{
    rbffi_StructLayoutClass = rb_define_class_under(moduleFFI, "StructLayout", rbffi_TypeClass);
    rb_global_variable(&rbffi_StructLayoutClass);
    
    rbffi_StructLayoutFieldClass = rb_define_class_under(rbffi_StructLayoutClass, "Field", rb_cObject);
    rb_global_variable(&rbffi_StructLayoutFieldClass);

    rbffi_StructLayoutFunctionFieldClass = rb_define_class_under(rbffi_StructLayoutClass, "Function", rbffi_StructLayoutFieldClass);
    rb_global_variable(&rbffi_StructLayoutFunctionFieldClass);

    rbffi_StructLayoutArrayFieldClass = rb_define_class_under(rbffi_StructLayoutClass, "Array", rbffi_StructLayoutFieldClass);
    rb_global_variable(&rbffi_StructLayoutArrayFieldClass);

    rb_define_alloc_func(rbffi_StructLayoutFieldClass, struct_field_allocate);
    rb_define_method(rbffi_StructLayoutFieldClass, "initialize", struct_field_initialize, -1);
    rb_define_method(rbffi_StructLayoutFieldClass, "offset", struct_field_offset, 0);
    rb_define_method(rbffi_StructLayoutFieldClass, "size", struct_field_size, 0);
    rb_define_method(rbffi_StructLayoutFieldClass, "alignment", struct_field_alignment, 0);
    rb_define_method(rbffi_StructLayoutFieldClass, "name", struct_field_name, 0);
    rb_define_method(rbffi_StructLayoutFieldClass, "type", struct_field_type, 0);
    rb_define_method(rbffi_StructLayoutFieldClass, "put", struct_field_put, 2);
    rb_define_method(rbffi_StructLayoutFieldClass, "get", struct_field_get, 1);

    rb_define_method(rbffi_StructLayoutFunctionFieldClass, "put", function_field_put, 2);
    rb_define_method(rbffi_StructLayoutFunctionFieldClass, "get", function_field_get, 1);

    rb_define_method(rbffi_StructLayoutArrayFieldClass, "get", array_field_get, 1);
    rb_define_method(rbffi_StructLayoutArrayFieldClass, "put", array_field_put, 2);

    rb_define_alloc_func(rbffi_StructLayoutClass, struct_layout_allocate);
    rb_define_method(rbffi_StructLayoutClass, "initialize", struct_layout_initialize, 4);
    rb_define_method(rbffi_StructLayoutClass, "[]", struct_layout_aref, 1);
    rb_define_method(rbffi_StructLayoutClass, "fields", struct_layout_fields, 0);
    rb_define_method(rbffi_StructLayoutClass, "members", struct_layout_members, 0);
    rb_define_method(rbffi_StructLayoutClass, "to_a", struct_layout_to_a, 0);

}
