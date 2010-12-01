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

typedef struct StructLayoutBuilder {
    VALUE rbFieldNames;
    VALUE rbFieldMap;
    unsigned int size;
    unsigned int alignment;
    bool isUnion;
} StructLayoutBuilder;

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
static void struct_layout_builder_mark(StructLayoutBuilder *);
static void struct_layout_builder_free(StructLayoutBuilder *);
static VALUE struct_class_layout(VALUE klass);
static void struct_malloc(Struct* s);
static void inline_array_mark(InlineArray *);

static inline int align(int offset, int align);

VALUE rbffi_StructClass = Qnil;
static VALUE StructLayoutBuilderClass = Qnil;

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
    VALUE obj = Data_Make_Struct(klass, Struct, struct_mark, -1, s);
    
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
}

static VALUE
struct_field(Struct* s, VALUE fieldName)
{
    StructLayout* layout = s->layout;
    VALUE rbField;

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
        rb_raise(rb_eArgError, "memory of %d bytes too small for struct %s (expected at least %d)",
                memory->size, rb_obj_classname(self), layout->base.ffiType->size);
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
struct_layout_builder_allocate(VALUE klass)
{
    StructLayoutBuilder* builder;
    VALUE obj;

    obj = Data_Make_Struct(klass, StructLayoutBuilder, struct_layout_builder_mark, struct_layout_builder_free, builder);

    builder->size = 0;
    builder->alignment = 1;
    builder->isUnion = false;
    builder->rbFieldNames = rb_ary_new();
    builder->rbFieldMap = rb_hash_new();

    return obj;
}

static void
struct_layout_builder_mark(StructLayoutBuilder* builder)
{
    rb_gc_mark(builder->rbFieldNames);
    rb_gc_mark(builder->rbFieldMap);
}

static void
struct_layout_builder_free(StructLayoutBuilder* builder)
{
    xfree(builder);
}

static VALUE
struct_layout_builder_initialize(VALUE self)
{
    StructLayoutBuilder* builder;

    Data_Get_Struct(self, StructLayoutBuilder, builder);

    return self;
}

static VALUE
struct_layout_builder_get_size(VALUE self)
{
    StructLayoutBuilder* builder;

    Data_Get_Struct(self, StructLayoutBuilder, builder);

    return UINT2NUM(builder->size);
}

static VALUE
struct_layout_builder_set_size(VALUE self, VALUE rbSize)
{
    StructLayoutBuilder* builder;
    unsigned int size = NUM2UINT(rbSize);

    Data_Get_Struct(self, StructLayoutBuilder, builder);
    builder->size = MAX(size, builder->size);

    return UINT2NUM(builder->size);
}

static VALUE
struct_layout_builder_get_alignment(VALUE self)
{
    StructLayoutBuilder* builder;

    Data_Get_Struct(self, StructLayoutBuilder, builder);

    return UINT2NUM(builder->alignment);
}

static VALUE
struct_layout_builder_set_alignment(VALUE self, VALUE rbAlign)
{
    StructLayoutBuilder* builder;
    unsigned int align = NUM2UINT(rbAlign);

    Data_Get_Struct(self, StructLayoutBuilder, builder);
    builder->size = MAX(align, builder->alignment);

    return UINT2NUM(builder->alignment);
}

static VALUE
struct_layout_builder_set_union(VALUE self, VALUE rbUnion)
{
    StructLayoutBuilder* builder;


    Data_Get_Struct(self, StructLayoutBuilder, builder);
    builder->isUnion = RTEST(rbUnion);

    return rbUnion;
}

static VALUE
struct_layout_builder_union_p(VALUE self)
{
    StructLayoutBuilder* builder;


    Data_Get_Struct(self, StructLayoutBuilder, builder);


    return builder->isUnion ? Qtrue : Qfalse;
}

static void
store_field(StructLayoutBuilder* builder, VALUE rbName, VALUE rbField, 
    unsigned int offset, unsigned int size, unsigned int alignment)
{
    rb_ary_push(builder->rbFieldNames, rbName);
    rb_hash_aset(builder->rbFieldMap, rbName, rbField);

    builder->alignment = MAX(builder->alignment, alignment);

    if (builder->isUnion) {
        builder->size = MAX(builder->size, size);
    } else {
        builder->size = MAX(builder->size, offset + size);
    }
}

static int
calculate_offset(StructLayoutBuilder* builder, int alignment, VALUE rbOffset)
{
    if (rbOffset != Qnil) {
        return NUM2UINT(rbOffset);
    } else {
        return builder->isUnion ? 0 : align(builder->size, alignment);
    }
}

static VALUE
struct_layout_builder_add_field(int argc, VALUE* argv, VALUE self)
{
    StructLayoutBuilder* builder;
    VALUE rbName = Qnil, rbType = Qnil, rbOffset = Qnil, rbField = Qnil;
    unsigned int size, alignment, offset;
    int nargs;

    nargs = rb_scan_args(argc, argv, "21", &rbName, &rbType, &rbOffset);
    
    Data_Get_Struct(self, StructLayoutBuilder, builder);

    alignment = NUM2UINT(rb_funcall2(rbType, rb_intern("alignment"), 0, NULL));
    size = NUM2UINT(rb_funcall2(rbType, rb_intern("size"), 0, NULL));

    offset = calculate_offset(builder, alignment, rbOffset);

    //
    // If a primitive type was passed in as the type arg, try and convert
    //
    if (!rb_obj_is_kind_of(rbType, rbffi_StructLayoutFieldClass)) {
        VALUE fargv[3], rbFieldClass;
        fargv[0] = rbName;
        fargv[1] = UINT2NUM(offset);
        fargv[2] = rbType;
        
        if (rb_obj_is_kind_of(rbType, rbffi_FunctionTypeClass)) {

            rbFieldClass = rbffi_StructLayoutFunctionFieldClass;

        } else if (rb_obj_is_kind_of(rbType, rbffi_StructByValueClass)) {
            
            rbFieldClass = rb_const_get(rbffi_StructLayoutClass, rb_intern("InlineStruct"));

        } else if (rb_obj_is_kind_of(rbType, rbffi_ArrayTypeClass)) {

            rbFieldClass = rbffi_StructLayoutArrayFieldClass;

        } else if (rb_obj_is_kind_of(rbType, rbffi_EnumTypeClass)) {

            rbFieldClass = rb_const_get(rbffi_StructLayoutClass, rb_intern("Enum"));

        } else {
            rbFieldClass = rbffi_StructLayoutFieldClass;
        }

        if (!RTEST(rbFieldClass)) {
            rb_raise(rb_eTypeError, "invalid struct field type (%s)", rb_obj_classname(rbType));
            return Qnil;
        }

        rbField = rb_class_new_instance(3, fargv, rbFieldClass);
    } else {
        rbField = rbType;
    }

    store_field(builder, rbName, rbField, offset, size, alignment);
    
    return self;
}

static VALUE
struct_layout_builder_add_struct(int argc, VALUE* argv, VALUE self)
{
    StructLayoutBuilder* builder;
    VALUE rbName = Qnil, rbType = Qnil, rbOffset = Qnil, rbField = Qnil;
    VALUE rbFieldClass = Qnil, rbStructClass = Qnil;
    VALUE fargv[3];
    unsigned int size, alignment, offset;
    int nargs;

    nargs = rb_scan_args(argc, argv, "21", &rbName, &rbStructClass, &rbOffset);

    if (!rb_obj_is_instance_of(rbStructClass, rb_cClass) || !rb_class_inherited(rbStructClass, rbffi_StructClass)) {
        rb_raise(rb_eTypeError, "wrong argument type.  Expected subclass of FFI::Struct");
    }

    rbType = rb_class_new_instance(1, &rbStructClass, rbffi_StructByValueClass);

    alignment = NUM2UINT(rb_funcall2(rbType, rb_intern("alignment"), 0, NULL));
    size = NUM2UINT(rb_funcall2(rbType, rb_intern("size"), 0, NULL));

    Data_Get_Struct(self, StructLayoutBuilder, builder);

    offset = calculate_offset(builder, alignment, rbOffset);

    fargv[0] = rbName;
    fargv[1] = UINT2NUM(offset);
    fargv[2] = rbType;
    rbFieldClass = rb_const_get(rbffi_StructLayoutClass, rb_intern("InlineStruct"));
    if (!RTEST(rbFieldClass)) {
        rb_raise(rb_eRuntimeError, "could not locate StructLayout::InlineStruct");
        return Qnil;
    }
    
    rbField = rb_class_new_instance(3, fargv, rbFieldClass);

    store_field(builder, rbName, rbField, offset, size, alignment);

    return self;
}

static VALUE
struct_layout_builder_add_array(int argc, VALUE* argv, VALUE self)
{
    StructLayoutBuilder* builder;
    VALUE rbName = Qnil, rbType = Qnil, rbLength = Qnil, rbOffset = Qnil, rbField;
    VALUE fargv[3], aargv[2];
    unsigned int size, alignment, offset;
    int nargs;

    nargs = rb_scan_args(argc, argv, "31", &rbName, &rbType, &rbLength, &rbOffset);

    Data_Get_Struct(self, StructLayoutBuilder, builder);

    alignment = NUM2UINT(rb_funcall2(rbType, rb_intern("alignment"), 0, NULL));
    size = NUM2UINT(rb_funcall2(rbType, rb_intern("size"), 0, NULL)) * NUM2UINT(rbLength);

    offset = calculate_offset(builder, alignment, rbOffset);

    aargv[0] = rbType;
    aargv[1] = rbLength;
    fargv[0] = rbName;
    fargv[1] = UINT2NUM(offset);
    fargv[2] = rb_class_new_instance(2, aargv, rbffi_ArrayTypeClass);
    rbField = rb_class_new_instance(3, fargv, rbffi_StructLayoutArrayFieldClass);

    store_field(builder, rbName, rbField, offset, size, alignment);

    return self;
}

static inline int
align(int offset, int align)
{
    return align + ((offset - 1) & ~(align - 1));
}

static VALUE
struct_layout_builder_build(VALUE self)
{
    StructLayoutBuilder* builder;
    VALUE argv[4];

    Data_Get_Struct(self, StructLayoutBuilder, builder);

    argv[0] = builder->rbFieldNames;
    argv[1] = builder->rbFieldMap;
    argv[2] = UINT2NUM(align(builder->size, builder->alignment)); // tail padding
    argv[3] = UINT2NUM(builder->alignment);

    return rb_class_new_instance(4, argv, rbffi_StructLayoutClass);
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
    array->length = array->arrayType->length;

    return self;
}

static VALUE
inline_array_size(VALUE self)
{
    InlineArray* array;

    Data_Get_Struct(self, InlineArray, array);

    return UINT2NUM(array->field->type->ffiType->size);
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
        return array->op->get(array->memory, inline_array_offset(array, NUM2INT(rbIndex)));
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
    
    if (array->op != NULL) {
        for (i = 0; i < array->length; ++i) {
            int offset = inline_array_offset(array, i);
            rb_yield(array->op->get(array->memory, offset));
        }
    } else if (array->componentType->nativeType == NATIVE_STRUCT) {
        for (i = 0; i < array->length; ++i) {
            VALUE rbOffset = UINT2NUM(inline_array_offset(array, i));
            VALUE rbLength = UINT2NUM(array->componentType->ffiType->size);
            VALUE rbPointer = rb_funcall(array->rbMemory, rb_intern("slice"), 2, rbOffset, rbLength);

            rb_yield(rb_class_new_instance(1, &rbPointer, ((StructByValue *) array->componentType)->rbStructClass));
        }
    } else {
        ArrayType* arrayType;
        Data_Get_Struct(array->field->rbType, ArrayType, arrayType);

        rb_raise(rb_eArgError, "get not supported for %s", rb_obj_classname(arrayType->rbComponentType));
        return Qnil;
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
        int offset = inline_array_offset(array, i);
        rb_ary_push(obj, array->op->get(array->memory, offset));
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


    StructLayoutBuilderClass = rb_define_class_under(moduleFFI, "StructLayoutBuilder", rb_cObject);
    rb_global_variable(&StructLayoutBuilderClass);

    rbffi_StructInlineArrayClass = rb_define_class_under(rbffi_StructClass, "InlineArray", rb_cObject);
    rb_global_variable(&rbffi_StructInlineArrayClass);

    rbffi_StructLayoutCharArrayClass = rb_define_class_under(rbffi_StructLayoutClass,
        "CharArray", rbffi_StructInlineArrayClass);
    rb_global_variable(&rbffi_StructLayoutCharArrayClass);


    rb_define_alloc_func(StructClass, struct_allocate);
    rb_define_method(StructClass, "initialize", struct_initialize, -1);
    
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
    
    

    rb_define_alloc_func(StructLayoutBuilderClass, struct_layout_builder_allocate);
    rb_define_method(StructLayoutBuilderClass, "initialize", struct_layout_builder_initialize, 0);
    rb_define_method(StructLayoutBuilderClass, "build", struct_layout_builder_build, 0);

    rb_define_method(StructLayoutBuilderClass, "alignment", struct_layout_builder_get_alignment, 0);
    rb_define_method(StructLayoutBuilderClass, "alignment=", struct_layout_builder_set_alignment, 1);
    rb_define_method(StructLayoutBuilderClass, "size", struct_layout_builder_get_size, 0);
    rb_define_method(StructLayoutBuilderClass, "size=", struct_layout_builder_set_size, 1);
    rb_define_method(StructLayoutBuilderClass, "union=", struct_layout_builder_set_union, 1);
    rb_define_method(StructLayoutBuilderClass, "union?", struct_layout_builder_union_p, 0);
    rb_define_method(StructLayoutBuilderClass, "add_field", struct_layout_builder_add_field, -1);
    rb_define_method(StructLayoutBuilderClass, "add_array", struct_layout_builder_add_array, -1);
    rb_define_method(StructLayoutBuilderClass, "add_struct", struct_layout_builder_add_struct, -1);

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
