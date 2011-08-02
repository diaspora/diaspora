/*
 * Copyright (c) 2008, 2009, Wayne Meissner
 * Copyright (c) 2009, Luc Heinrich <luc@honk-honk.com>
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
#include "MappedType.h"

typedef struct InlineArray_ {
    VALUE rbMemory;
    VALUE rbField;

    AbstractMemory* memory;
    StructField* field;
    MemoryOp *op;
    Type* componentType;
    ArrayType* arrayType;
    unsigned int length;
} InlineArray;


static void struct_mark(Struct *);
static void struct_free(Struct *);
static VALUE struct_class_layout(VALUE klass);
static void struct_malloc(Struct* s);
static void inline_array_mark(InlineArray *);
static void store_reference_value(StructField* f, Struct* s, VALUE value);

VALUE rbffi_StructClass = Qnil;

VALUE rbffi_StructInlineArrayClass = Qnil;
VALUE rbffi_StructLayoutCharArrayClass = Qnil;

static ID id_pointer_ivar = 0, id_layout_ivar = 0;
static ID id_get = 0, id_put = 0, id_to_ptr = 0, id_to_s = 0, id_layout = 0;

static inline char*
memory_address(VALUE self)
{
    return ((AbstractMemory *)DATA_PTR((self)))->address;
}

static VALUE
struct_allocate(VALUE klass)
{
    Struct* s;
    VALUE obj = Data_Make_Struct(klass, Struct, struct_mark, struct_free, s);
    
    s->rbPointer = Qnil;
    s->rbLayout = Qnil;

    return obj;
}

static VALUE
struct_initialize(int argc, VALUE* argv, VALUE self)
{
    Struct* s;
    VALUE rbPointer = Qnil, rest = Qnil, klass = CLASS_OF(self);
    int nargs;

    Data_Get_Struct(self, Struct, s);
    
    nargs = rb_scan_args(argc, argv, "01*", &rbPointer, &rest);

    /* Call up into ruby code to adjust the layout */
    if (nargs > 1) {
        s->rbLayout = rb_funcall2(CLASS_OF(self), id_layout, RARRAY_LEN(rest), RARRAY_PTR(rest));
    } else {
        s->rbLayout = struct_class_layout(klass);
    }

    if (!rb_obj_is_kind_of(s->rbLayout, rbffi_StructLayoutClass)) {
        rb_raise(rb_eRuntimeError, "Invalid Struct layout");
    }

    Data_Get_Struct(s->rbLayout, StructLayout, s->layout);
    
    if (rbPointer != Qnil) {
        s->pointer = MEMORY(rbPointer);
        s->rbPointer = rbPointer;
    } else {
        struct_malloc(s);
    }

    return self;
}

static VALUE
struct_initialize_copy(VALUE self, VALUE other)
{
    Struct* src;
    Struct* dst;
    VALUE memargs[3];
    
    Data_Get_Struct(self, Struct, dst);
    Data_Get_Struct(other, Struct, src);
    if (dst == src) {
        return self;
    }
    
    dst->rbLayout = src->rbLayout;
    dst->layout = src->layout;
    
    //
    // A new MemoryPointer instance is allocated here instead of just calling 
    // #dup on rbPointer, since the Pointer may not know its length, or may
    // be longer than just this struct.
    //
    if (src->pointer->address != NULL) {
        memargs[0] = INT2FIX(1);
        memargs[1] = INT2FIX(src->layout->size);
        memargs[2] = Qfalse;
        dst->rbPointer = rb_class_new_instance(2, memargs, rbffi_MemoryPointerClass);
        dst->pointer = MEMORY(dst->rbPointer);
        memcpy(dst->pointer->address, src->pointer->address, src->layout->size);
    } else {
        dst->rbPointer = src->rbPointer;
        dst->pointer = src->pointer;
    }

    if (src->layout->referenceFieldCount > 0) {
        dst->rbReferences = ALLOC_N(VALUE, dst->layout->referenceFieldCount);
        memcpy(dst->rbReferences, src->rbReferences, dst->layout->referenceFieldCount * sizeof(VALUE));
    }
        
    return self;
}

static VALUE
struct_class_layout(VALUE klass)
{
    VALUE layout;
    if (!rb_cvar_defined(klass, id_layout_ivar)) {
        rb_raise(rb_eRuntimeError, "no Struct layout configured for %s", rb_class2name(klass));
    }

    layout = rb_cvar_get(klass, id_layout_ivar);
    if (!rb_obj_is_kind_of(layout, rbffi_StructLayoutClass)) {
        rb_raise(rb_eRuntimeError, "invalid Struct layout for %s", rb_class2name(klass));
    }

    return layout;
}

static StructLayout*
struct_layout(VALUE self)
{
    Struct* s = (Struct *) DATA_PTR(self);
    if (s->layout != NULL) {
        return s->layout;
    }

    if (s->layout == NULL) {
        s->rbLayout = struct_class_layout(CLASS_OF(self));
        Data_Get_Struct(s->rbLayout, StructLayout, s->layout);
    }

    return s->layout;
}

static Struct*
struct_validate(VALUE self)
{
    Struct* s;
    Data_Get_Struct(self, Struct, s);

    if (struct_layout(self) == NULL) {
        rb_raise(rb_eRuntimeError, "struct layout == null");
    }

    if (s->pointer == NULL) {
        struct_malloc(s);
    }

    return s;
}

static void
struct_malloc(Struct* s)
{
    if (s->rbPointer == Qnil) {
        s->rbPointer = rbffi_MemoryPointer_NewInstance(s->layout->size, 1, true);

    } else if (!rb_obj_is_kind_of(s->rbPointer, rbffi_AbstractMemoryClass)) {
        rb_raise(rb_eRuntimeError, "invalid pointer in struct");
    }

    s->pointer = (AbstractMemory *) DATA_PTR(s->rbPointer);
}

static void
struct_mark(Struct *s)
{
    rb_gc_mark(s->rbPointer);
    rb_gc_mark(s->rbLayout);
    if (s->rbReferences != NULL) {
        rb_gc_mark_locations(&s->rbReferences[0], &s->rbReferences[s->layout->referenceFieldCount]);
    }
}

static void
struct_free(Struct* s)
{
    xfree(s->rbReferences);
    xfree(s);
}


static void
store_reference_value(StructField* f, Struct* s, VALUE value)
{
    if (unlikely(f->referenceIndex == -1)) {
        rb_raise(rb_eRuntimeError, "put_reference_value called for non-reference type");
        return;
    }
    if (s->rbReferences == NULL) {
        int i;
        s->rbReferences = ALLOC_N(VALUE, s->layout->referenceFieldCount);
        for (i = 0; i < s->layout->referenceFieldCount; ++i) {
            s->rbReferences[i] = Qnil;
        }
    }

    s->rbReferences[f->referenceIndex] = value;
}


static VALUE
struct_field(Struct* s, VALUE fieldName)
{
    StructLayout* layout = s->layout;
    VALUE rbField;

    if (likely(SYMBOL_P(fieldName) && st_lookup(layout->fieldSymbolTable, fieldName, (st_data_t *) &rbField))) {
        return rbField;
    }

    rbField = rb_hash_aref(layout->rbFieldMap, fieldName);
    if (rbField == Qnil) {
        VALUE str = rb_funcall2(fieldName, id_to_s, 0, NULL);
        rb_raise(rb_eArgError, "No such field '%s'", StringValuePtr(str));
    }

    return rbField;
}

static VALUE
struct_aref(VALUE self, VALUE fieldName)
{
    Struct* s;
    VALUE rbField;
    StructField* f;

    s = struct_validate(self);

    rbField = struct_field(s, fieldName);
    f = (StructField *) DATA_PTR(rbField);

    if (f->get != NULL) {
        return (*f->get)(f, s);
    
    } else if (f->memoryOp != NULL) {
        return (*f->memoryOp->get)(s->pointer, f->offset);

    } else {
    
        /* call up to the ruby code to fetch the value */
        return rb_funcall2(rbField, id_get, 1, &s->rbPointer);
    }
}

static VALUE
struct_aset(VALUE self, VALUE fieldName, VALUE value)
{
    Struct* s;
    VALUE rbField;
    StructField* f;


    s = struct_validate(self);

    rbField = struct_field(s, fieldName);
    f = (StructField *) DATA_PTR(rbField);
    if (f->put != NULL) {
        (*f->put)(f, s, value);

    } else if (f->memoryOp != NULL) {

        (*f->memoryOp->put)(s->pointer, f->offset, value);
    
    } else {
        /* call up to the ruby code to set the value */
        VALUE argv[2];
        argv[0] = s->rbPointer;
        argv[1] = value;
        rb_funcall2(rbField, id_put, 2, argv);
    }

    if (f->referenceRequired) {
        store_reference_value(f, s, value);
    }
    
    return value;
}

static VALUE
struct_set_pointer(VALUE self, VALUE pointer)
{
    Struct* s;
    StructLayout* layout;
    AbstractMemory* memory;

    if (!rb_obj_is_kind_of(pointer, rbffi_AbstractMemoryClass)) {
        rb_raise(rb_eTypeError, "wrong argument type %s (expected Pointer or Buffer)",
                rb_obj_classname(pointer));
        return Qnil;
    }

    
    Data_Get_Struct(self, Struct, s);
    Data_Get_Struct(pointer, AbstractMemory, memory);
    layout = struct_layout(self);

    if (layout->base.ffiType->size > memory->size) {
        rb_raise(rb_eArgError, "memory of %ld bytes too small for struct %s (expected at least %ld)",
                memory->size, rb_obj_classname(self), (long) layout->base.ffiType->size);
    }
    
    s->pointer = MEMORY(pointer);
    s->rbPointer = pointer;
    rb_ivar_set(self, id_pointer_ivar, pointer);

    return self;
}

static VALUE
struct_get_pointer(VALUE self)
{
    Struct* s;

    Data_Get_Struct(self, Struct, s);

    return s->rbPointer;
}

static VALUE
struct_set_layout(VALUE self, VALUE layout)
{
    Struct* s;
    Data_Get_Struct(self, Struct, s);

    if (!rb_obj_is_kind_of(layout, rbffi_StructLayoutClass)) {
        rb_raise(rb_eTypeError, "wrong argument type %s (expected %s)",
                rb_obj_classname(layout), rb_class2name(rbffi_StructLayoutClass));
        return Qnil;
    }

    Data_Get_Struct(layout, StructLayout, s->layout);
    rb_ivar_set(self, id_layout_ivar, layout);

    return self;
}

static VALUE
struct_get_layout(VALUE self)
{
    Struct* s;

    Data_Get_Struct(self, Struct, s);

    return s->rbLayout;
}


static VALUE
struct_null_p(VALUE self)
{
    Struct* s;

    Data_Get_Struct(self, Struct, s);

    return s->pointer->address == NULL ? Qtrue : Qfalse;
}

static VALUE
struct_order(int argc, VALUE* argv, VALUE self)
{
    Struct* s;

    Data_Get_Struct(self, Struct, s);
    if (argc == 0) {
        return rb_funcall(s->rbPointer, rb_intern("order"), 0);

    } else {
        VALUE retval = rb_obj_dup(self);
        VALUE rbPointer = rb_funcall2(s->rbPointer, rb_intern("order"), argc, argv);
        struct_set_pointer(retval, rbPointer);
        
        return retval;
    }
}


static VALUE
inline_array_allocate(VALUE klass)
{
    InlineArray* array;
    VALUE obj;

    obj = Data_Make_Struct(klass, InlineArray, inline_array_mark, -1, array);
    array->rbField = Qnil;
    array->rbMemory = Qnil;

    return obj;
}

static void
inline_array_mark(InlineArray* array)
{
    rb_gc_mark(array->rbField);
    rb_gc_mark(array->rbMemory);
}

static VALUE
inline_array_initialize(VALUE self, VALUE rbMemory, VALUE rbField)
{
    InlineArray* array;
    
    Data_Get_Struct(self, InlineArray, array);
    array->rbMemory = rbMemory;
    array->rbField = rbField;

    Data_Get_Struct(rbMemory, AbstractMemory, array->memory);
    Data_Get_Struct(rbField, StructField, array->field);
    Data_Get_Struct(array->field->rbType, ArrayType, array->arrayType);
    Data_Get_Struct(array->arrayType->rbComponentType, Type, array->componentType);
    
    array->op = get_memory_op(array->componentType);
    if (array->op == NULL && array->componentType->nativeType == NATIVE_MAPPED) {
        array->op = get_memory_op(((MappedType *) array->componentType)->type);
    }
    
    array->length = array->arrayType->length;

    return self;
}

static VALUE
inline_array_size(VALUE self)
{
    InlineArray* array;

    Data_Get_Struct(self, InlineArray, array);

    return UINT2NUM(((ArrayType *) array->field->type)->length);
}

static int
inline_array_offset(InlineArray* array, int index)
{
    if (index < 0 || index >= array->length) {
        rb_raise(rb_eIndexError, "index %d out of bounds", index);
    }

    return array->field->offset + (index * array->componentType->ffiType->size);
}

static VALUE
inline_array_aref(VALUE self, VALUE rbIndex)
{
    InlineArray* array;

    Data_Get_Struct(self, InlineArray, array);

    if (array->op != NULL) {
        VALUE rbNativeValue = array->op->get(array->memory, 
                inline_array_offset(array, NUM2INT(rbIndex)));
        if (unlikely(array->componentType->nativeType == NATIVE_MAPPED)) {
            return rb_funcall(((MappedType *) array->componentType)->rbConverter, 
                    rb_intern("from_native"), 2, rbNativeValue, Qnil);
        } else {
            return rbNativeValue; 
        }
        
    } else if (array->componentType->nativeType == NATIVE_STRUCT) {
        VALUE rbOffset = INT2NUM(inline_array_offset(array, NUM2INT(rbIndex)));
        VALUE rbLength = INT2NUM(array->componentType->ffiType->size);
        VALUE rbPointer = rb_funcall(array->rbMemory, rb_intern("slice"), 2, rbOffset, rbLength);

        return rb_class_new_instance(1, &rbPointer, ((StructByValue *) array->componentType)->rbStructClass);
    } else {

        rb_raise(rb_eArgError, "get not supported for %s", rb_obj_classname(array->arrayType->rbComponentType));
        return Qnil;
    }
}

static VALUE
inline_array_aset(VALUE self, VALUE rbIndex, VALUE rbValue)
{
    InlineArray* array;

    Data_Get_Struct(self, InlineArray, array);

    if (array->op != NULL) {
        if (unlikely(array->componentType->nativeType == NATIVE_MAPPED)) {
            rbValue = rb_funcall(((MappedType *) array->componentType)->rbConverter, 
                    rb_intern("to_native"), 2, rbValue, Qnil);
        }
        array->op->put(array->memory, inline_array_offset(array, NUM2INT(rbIndex)),
            rbValue);
        
    } else if (array->componentType->nativeType == NATIVE_STRUCT) {
        int offset = inline_array_offset(array, NUM2INT(rbIndex));
        Struct* s;

        if (!rb_obj_is_kind_of(rbValue, rbffi_StructClass)) {
            rb_raise(rb_eTypeError, "argument not an instance of struct");
            return Qnil;
        }

        checkWrite(array->memory);
        checkBounds(array->memory, offset, array->componentType->ffiType->size);

        Data_Get_Struct(rbValue, Struct, s);
        checkRead(s->pointer);
        checkBounds(s->pointer, 0, array->componentType->ffiType->size);

        memcpy(array->memory->address + offset, s->pointer->address, array->componentType->ffiType->size);

    } else {
        ArrayType* arrayType;
        Data_Get_Struct(array->field->rbType, ArrayType, arrayType);

        rb_raise(rb_eArgError, "set not supported for %s", rb_obj_classname(arrayType->rbComponentType));
        return Qnil;
    }

    return rbValue;
}

static VALUE
inline_array_each(VALUE self)
{
    InlineArray* array;
    
    int i;

    Data_Get_Struct(self, InlineArray, array);
    
    for (i = 0; i < array->length; ++i) {
        rb_yield(inline_array_aref(self, INT2FIX(i)));
    }

    return self;
}

static VALUE
inline_array_to_a(VALUE self)
{
    InlineArray* array;
    VALUE obj;
    int i;

    Data_Get_Struct(self, InlineArray, array);
    obj = rb_ary_new2(array->length);

    
    for (i = 0; i < array->length; ++i) {
        rb_ary_push(obj, inline_array_aref(self, INT2FIX(i)));
    }

    return obj;
}

static VALUE
inline_array_to_s(VALUE self)
{
    InlineArray* array;
    VALUE argv[2];

    Data_Get_Struct(self, InlineArray, array);
 
    if (array->componentType->nativeType != NATIVE_INT8 && array->componentType->nativeType != NATIVE_UINT8) {
        VALUE dummy = Qnil;
        return rb_call_super(0, &dummy);
    }

    argv[0] = UINT2NUM(array->field->offset);
    argv[1] = UINT2NUM(array->length);

    return rb_funcall2(array->rbMemory, rb_intern("get_string"), 2, argv);
}


static VALUE
inline_array_to_ptr(VALUE self)
{
    InlineArray* array;
    
    Data_Get_Struct(self, InlineArray, array);

    return rb_funcall(array->rbMemory, rb_intern("slice"), 2,
        UINT2NUM(array->field->offset), UINT2NUM(array->arrayType->base.ffiType->size));
}


void
rbffi_Struct_Init(VALUE moduleFFI)
{
    VALUE StructClass;

    rbffi_StructLayout_Init(moduleFFI);

    rbffi_StructClass = StructClass = rb_define_class_under(moduleFFI, "Struct", rb_cObject);
    rb_global_variable(&rbffi_StructClass);

    rbffi_StructInlineArrayClass = rb_define_class_under(rbffi_StructClass, "InlineArray", rb_cObject);
    rb_global_variable(&rbffi_StructInlineArrayClass);

    rbffi_StructLayoutCharArrayClass = rb_define_class_under(rbffi_StructLayoutClass,
        "CharArray", rbffi_StructInlineArrayClass);
    rb_global_variable(&rbffi_StructLayoutCharArrayClass);


    rb_define_alloc_func(StructClass, struct_allocate);
    rb_define_method(StructClass, "initialize", struct_initialize, -1);
    rb_define_method(StructClass, "initialize_copy", struct_initialize_copy, 1);
    rb_define_method(StructClass, "order", struct_order, -1);
    
    rb_define_alias(rb_singleton_class(StructClass), "alloc_in", "new");
    rb_define_alias(rb_singleton_class(StructClass), "alloc_out", "new");
    rb_define_alias(rb_singleton_class(StructClass), "alloc_inout", "new");
    rb_define_alias(rb_singleton_class(StructClass), "new_in", "new");
    rb_define_alias(rb_singleton_class(StructClass), "new_out", "new");
    rb_define_alias(rb_singleton_class(StructClass), "new_inout", "new");

    rb_define_method(StructClass, "pointer", struct_get_pointer, 0);
    rb_define_private_method(StructClass, "pointer=", struct_set_pointer, 1);

    rb_define_method(StructClass, "layout", struct_get_layout, 0);
    rb_define_private_method(StructClass, "layout=", struct_set_layout, 1);

    rb_define_method(StructClass, "[]", struct_aref, 1);
    rb_define_method(StructClass, "[]=", struct_aset, 2);
    rb_define_method(StructClass, "null?", struct_null_p, 0);

    rb_include_module(rbffi_StructInlineArrayClass, rb_mEnumerable);
    rb_define_alloc_func(rbffi_StructInlineArrayClass, inline_array_allocate);
    rb_define_method(rbffi_StructInlineArrayClass, "initialize", inline_array_initialize, 2);
    rb_define_method(rbffi_StructInlineArrayClass, "[]", inline_array_aref, 1);
    rb_define_method(rbffi_StructInlineArrayClass, "[]=", inline_array_aset, 2);
    rb_define_method(rbffi_StructInlineArrayClass, "each", inline_array_each, 0);
    rb_define_method(rbffi_StructInlineArrayClass, "size", inline_array_size, 0);
    rb_define_method(rbffi_StructInlineArrayClass, "to_a", inline_array_to_a, 0);
    rb_define_method(rbffi_StructInlineArrayClass, "to_ptr", inline_array_to_ptr, 0);

    rb_define_method(rbffi_StructLayoutCharArrayClass, "to_s", inline_array_to_s, 0);
    rb_define_alias(rbffi_StructLayoutCharArrayClass, "to_str", "to_s");

    id_pointer_ivar = rb_intern("@pointer");
    id_layout_ivar = rb_intern("@layout");
    id_layout = rb_intern("layout");
    id_get = rb_intern("get");
    id_put = rb_intern("put");
    id_to_ptr = rb_intern("to_ptr");
    id_to_s = rb_intern("to_s");
}

