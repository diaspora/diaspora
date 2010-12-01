/*
 * Copyright (c) 2008, 2009, Wayne Meissner
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
#include <sys/param.h>
#include <stdint.h>
#include <stdbool.h>
#include <ruby.h>
#include "rbffi.h"
#include "compat.h"
#include "AbstractMemory.h"
#include "Pointer.h"
#include "Function.h"


static inline char* memory_address(VALUE self);
VALUE rbffi_AbstractMemoryClass = Qnil;
static VALUE NullPointerErrorClass = Qnil;
static ID id_to_ptr = 0, id_plus = 0, id_call = 0;

static VALUE
memory_allocate(VALUE klass)
{
    AbstractMemory* memory;
    VALUE obj;
    obj = Data_Make_Struct(klass, AbstractMemory, NULL, -1, memory);
    memory->access = MEM_RD | MEM_WR;

    return obj;
}

#define NUM_OP(name, type, toNative, fromNative) \
static void memory_op_put_##name(AbstractMemory* memory, long off, VALUE value); \
static void \
memory_op_put_##name(AbstractMemory* memory, long off, VALUE value) \
{ \
    type tmp = (type) toNative(value); \
    checkWrite(memory); \
    checkBounds(memory, off, sizeof(type)); \
    memcpy(memory->address + off, &tmp, sizeof(tmp)); \
} \
static VALUE memory_put_##name(VALUE self, VALUE offset, VALUE value); \
static VALUE \
memory_put_##name(VALUE self, VALUE offset, VALUE value) \
{ \
    AbstractMemory* memory; \
    Data_Get_Struct(self, AbstractMemory, memory); \
    memory_op_put_##name(memory, NUM2LONG(offset), value); \
    return self; \
} \
static VALUE memory_op_get_##name(AbstractMemory* memory, long off); \
static VALUE \
memory_op_get_##name(AbstractMemory* memory, long off) \
{ \
    type tmp; \
    checkRead(memory); \
    checkBounds(memory, off, sizeof(type)); \
    memcpy(&tmp, memory->address + off, sizeof(tmp)); \
    return fromNative(tmp); \
} \
static VALUE memory_get_##name(VALUE self, VALUE offset); \
static VALUE \
memory_get_##name(VALUE self, VALUE offset) \
{ \
    AbstractMemory* memory; \
    Data_Get_Struct(self, AbstractMemory, memory); \
    return memory_op_get_##name(memory, NUM2LONG(offset)); \
} \
static MemoryOp memory_op_##name = { memory_op_get_##name, memory_op_put_##name }; \
\
static VALUE memory_put_array_of_##name(VALUE self, VALUE offset, VALUE ary); \
static VALUE \
memory_put_array_of_##name(VALUE self, VALUE offset, VALUE ary) \
{ \
    long count = RARRAY_LEN(ary); \
    long off = NUM2LONG(offset); \
    AbstractMemory* memory = MEMORY(self); \
    long i; \
    checkWrite(memory); \
    checkBounds(memory, off, count * sizeof(type)); \
    for (i = 0; i < count; i++) { \
        type tmp = (type) toNative(RARRAY_PTR(ary)[i]); \
        memcpy(memory->address + off + (i * sizeof(type)), &tmp, sizeof(tmp)); \
    } \
    return self; \
} \
static VALUE memory_get_array_of_##name(VALUE self, VALUE offset, VALUE length); \
static VALUE \
memory_get_array_of_##name(VALUE self, VALUE offset, VALUE length) \
{ \
    long count = NUM2LONG(length); \
    long off = NUM2LONG(offset); \
    AbstractMemory* memory = MEMORY(self); \
    long i; \
    checkRead(memory); \
    checkBounds(memory, off, count * sizeof(type)); \
    VALUE retVal = rb_ary_new2(count); \
    for (i = 0; i < count; ++i) { \
        type tmp; \
        memcpy(&tmp, memory->address + off + (i * sizeof(type)), sizeof(tmp)); \
        rb_ary_push(retVal, fromNative(tmp)); \
    } \
    return retVal; \
}

NUM_OP(int8, int8_t, NUM2INT, INT2NUM);
NUM_OP(uint8, uint8_t, NUM2UINT, UINT2NUM);
NUM_OP(int16, int16_t, NUM2INT, INT2NUM);
NUM_OP(uint16, uint16_t, NUM2UINT, UINT2NUM);
NUM_OP(int32, int32_t, NUM2INT, INT2NUM);
NUM_OP(uint32, uint32_t, NUM2UINT, UINT2NUM);
NUM_OP(int64, int64_t, NUM2LL, LL2NUM);
NUM_OP(uint64, uint64_t, NUM2ULL, ULL2NUM);
NUM_OP(long, long, NUM2LONG, LONG2NUM);
NUM_OP(ulong, unsigned long, NUM2ULONG, ULONG2NUM);
NUM_OP(float32, float, NUM2DBL, rb_float_new);
NUM_OP(float64, double, NUM2DBL, rb_float_new);

static inline void*
get_pointer_value(VALUE value)
{
    const int type = TYPE(value);
    if (type == T_DATA && rb_obj_is_kind_of(value, rbffi_PointerClass)) {
        return memory_address(value);
    } else if (type == T_NIL) {
        return NULL;
    } else if (type == T_FIXNUM) {
        return (void *) (uintptr_t) FIX2INT(value);
    } else if (type == T_BIGNUM) {
        return (void *) (uintptr_t) NUM2ULL(value);
    } else if (rb_respond_to(value, id_to_ptr)) {
        return MEMORY_PTR(rb_funcall2(value, id_to_ptr, 0, NULL));
    } else {
        rb_raise(rb_eArgError, "value is not a pointer");
        return NULL;
    }
}

NUM_OP(pointer, void *, get_pointer_value, rbffi_Pointer_NewInstance);

static VALUE
memory_clear(VALUE self)
{
    AbstractMemory* ptr = MEMORY(self);
    memset(ptr->address, 0, ptr->size);
    return self;
}

static VALUE
memory_size(VALUE self) 
{
    AbstractMemory* ptr;

    Data_Get_Struct(self, AbstractMemory, ptr);

    return LONG2NUM(ptr->size);
}

static VALUE
memory_get_string(int argc, VALUE* argv, VALUE self)
{
    VALUE length = Qnil, offset = Qnil;
    AbstractMemory* ptr = MEMORY(self);
    long off, len;
    char* end;
    int nargs = rb_scan_args(argc, argv, "11", &offset, &length);

    off = NUM2LONG(offset);
    len = nargs > 1 && length != Qnil ? NUM2LONG(length) : (ptr->size - off);
    checkRead(ptr);
    checkBounds(ptr, off, len);

    end = memchr(ptr->address + off, 0, len);
    return rb_tainted_str_new((char *) ptr->address + off,
            (end != NULL ? end - ptr->address - off : len));
}

static VALUE
memory_get_array_of_string(int argc, VALUE* argv, VALUE self)
{
    VALUE offset = Qnil, countnum = Qnil, retVal = Qnil;
    AbstractMemory* ptr;
    long off;
    int count;

    rb_scan_args(argc, argv, "11", &offset, &countnum);
    off = NUM2LONG(offset);
    count = (countnum == Qnil ? 0 : NUM2INT(countnum));
    retVal = rb_ary_new2(count);

    Data_Get_Struct(self, AbstractMemory, ptr);
    checkRead(ptr);

    if (countnum != Qnil) {
        int i;

        checkBounds(ptr, off, count * sizeof (char*));
        
        for (i = 0; i < count; ++i) {
            const char* strptr = *((const char**) (ptr->address + off) + i);
            rb_ary_push(retVal, (strptr == NULL ? Qnil : rb_tainted_str_new2(strptr)));
        }

    } else {
        checkBounds(ptr, off, sizeof (char*));
        for ( ; off < ptr->size - (long) sizeof (void *); off += (long) sizeof (void *)) {
            const char* strptr = *(const char**) (ptr->address + off);
            if (strptr == NULL) {
                break;
            }
            rb_ary_push(retVal, rb_tainted_str_new2(strptr));
        }
    }

    return retVal;
}

static VALUE
memory_put_string(VALUE self, VALUE offset, VALUE str)
{
    AbstractMemory* ptr = MEMORY(self);
    long off, len;

    Check_Type(str, T_STRING);
    off = NUM2LONG(offset);
    len = RSTRING_LEN(str);

    checkWrite(ptr);
    checkBounds(ptr, off, len + 1);
    
    if (rb_safe_level() >= 1 && OBJ_TAINTED(str)) {
        rb_raise(rb_eSecurityError, "Writing unsafe string to memory");
        return Qnil;
    }

    memcpy(ptr->address + off, RSTRING_PTR(str), len);
    *((char *) ptr->address + off + len) = '\0';

    return self;
}

static VALUE
memory_get_bytes(VALUE self, VALUE offset, VALUE length)
{
    AbstractMemory* ptr = MEMORY(self);
    long off, len;
    
    off = NUM2LONG(offset);
    len = NUM2LONG(length);

    checkRead(ptr);
    checkBounds(ptr, off, len);
    
    return rb_tainted_str_new((char *) ptr->address + off, len);
}

static VALUE
memory_put_bytes(int argc, VALUE* argv, VALUE self)
{
    AbstractMemory* ptr = MEMORY(self);
    VALUE offset = Qnil, str = Qnil, rbIndex = Qnil, rbLength = Qnil;
    long off, len, idx;
    int nargs = rb_scan_args(argc, argv, "22", &offset, &str, &rbIndex, &rbLength);

    Check_Type(str, T_STRING);

    off = NUM2LONG(offset);
    idx = nargs > 2 ? NUM2LONG(rbIndex) : 0;
    if (idx < 0) {
        rb_raise(rb_eRangeError, "index canot be less than zero");
        return Qnil;
    }
    len = nargs > 3 ? NUM2LONG(rbLength) : (RSTRING_LEN(str) - idx);
    if ((idx + len) > RSTRING_LEN(str)) {
        rb_raise(rb_eRangeError, "index+length is greater than size of string");
        return Qnil;
    }

    checkWrite(ptr);
    checkBounds(ptr, off, len);

    if (rb_safe_level() >= 1 && OBJ_TAINTED(str)) {
        rb_raise(rb_eSecurityError, "Writing unsafe string to memory");
        return Qnil;
    }
    memcpy(ptr->address + off, RSTRING_PTR(str) + idx, len);

    return self;
}

static VALUE
memory_type_size(VALUE self)
{
    AbstractMemory* ptr;

    Data_Get_Struct(self, AbstractMemory, ptr);

    return INT2NUM(ptr->typeSize);
}

static VALUE
memory_aref(VALUE self, VALUE idx)
{
    AbstractMemory* ptr;
    VALUE rbOffset = Qnil;

    Data_Get_Struct(self, AbstractMemory, ptr);

    rbOffset = ULONG2NUM(NUM2ULONG(idx) * ptr->typeSize);

    return rb_funcall2(self, id_plus, 1, &rbOffset);
}

static inline char*
memory_address(VALUE obj)
{
    return ((AbstractMemory *) DATA_PTR(obj))->address;
}

AbstractMemory*
rbffi_AbstractMemory_Cast(VALUE obj, VALUE klass)
{
    if (rb_obj_is_kind_of(obj, klass)) {
        AbstractMemory* memory;
        Data_Get_Struct(obj, AbstractMemory, memory);
        return memory;
    }

    rb_raise(rb_eArgError, "Invalid Memory object");
    return NULL;
}

void
rbffi_AbstractMemory_Error(AbstractMemory *mem, int op)
{
    VALUE rbErrorClass = mem->address == NULL ? NullPointerErrorClass : rb_eRuntimeError;
    if (op == MEM_RD) {
        rb_raise(rbErrorClass, "invalid memory read at address=%p", mem->address);
    } else if (op == MEM_WR) {
        rb_raise(rbErrorClass, "invalid memory write at address=%p", mem->address);
    } else {
        rb_raise(rbErrorClass, "invalid memory access at address=%p", mem->address);
    }
}

static VALUE
memory_op_get_strptr(AbstractMemory* ptr, long offset)
{
    void* tmp = NULL;

    if (ptr != NULL && ptr->address != NULL) {
        checkRead(ptr);
        checkBounds(ptr, offset, sizeof(tmp));
        memcpy(&tmp, ptr->address + offset, sizeof(tmp));
    }

    return tmp != NULL ? rb_tainted_str_new2(tmp) : Qnil;
}

static void
memory_op_put_strptr(AbstractMemory* ptr, long offset, VALUE value)
{
    rb_raise(rb_eArgError, "Cannot set :string fields");
}

static MemoryOp memory_op_strptr = { memory_op_get_strptr, memory_op_put_strptr };

//static MemoryOp memory_op_pointer = { memory_op_get_pointer, memory_op_put_pointer };

MemoryOps rbffi_AbstractMemoryOps = {
    .int8 = &memory_op_int8,
    .uint8 = &memory_op_uint8,
    .int16 = &memory_op_int16,
    .uint16 = &memory_op_uint16,
    .int32 = &memory_op_int32,
    .uint32 = &memory_op_uint32,
    .int64 = &memory_op_int64,
    .uint64 = &memory_op_uint64,
    .slong = &memory_op_long,
    .ulong = &memory_op_ulong,
    .float32 = &memory_op_float32,
    .float64 = &memory_op_float64,
    .pointer = &memory_op_pointer,
    .strptr = &memory_op_strptr,
};

void
rbffi_AbstractMemory_Init(VALUE moduleFFI)
{
    VALUE classMemory = rb_define_class_under(moduleFFI, "AbstractMemory", rb_cObject);
    rbffi_AbstractMemoryClass = classMemory;
    rb_global_variable(&rbffi_AbstractMemoryClass);
    rb_define_alloc_func(classMemory, memory_allocate);

    NullPointerErrorClass = rb_define_class_under(moduleFFI, "NullPointerError", rb_eRuntimeError);
    rb_global_variable(&NullPointerErrorClass);


#undef INT
#define INT(type) \
    rb_define_method(classMemory, "put_" #type, memory_put_##type, 2); \
    rb_define_method(classMemory, "get_" #type, memory_get_##type, 1); \
    rb_define_method(classMemory, "put_u" #type, memory_put_u##type, 2); \
    rb_define_method(classMemory, "get_u" #type, memory_get_u##type, 1); \
    rb_define_method(classMemory, "put_array_of_" #type, memory_put_array_of_##type, 2); \
    rb_define_method(classMemory, "get_array_of_" #type, memory_get_array_of_##type, 2); \
    rb_define_method(classMemory, "put_array_of_u" #type, memory_put_array_of_u##type, 2); \
    rb_define_method(classMemory, "get_array_of_u" #type, memory_get_array_of_u##type, 2);
    
    INT(int8);
    INT(int16);
    INT(int32);
    INT(int64);
    INT(long);
    
#define ALIAS(name, old) \
    rb_define_alias(classMemory, "put_" #name, "put_" #old); \
    rb_define_alias(classMemory, "get_" #name, "get_" #old); \
    rb_define_alias(classMemory, "put_u" #name, "put_u" #old); \
    rb_define_alias(classMemory, "get_u" #name, "get_u" #old); \
    rb_define_alias(classMemory, "put_array_of_" #name, "put_array_of_" #old); \
    rb_define_alias(classMemory, "get_array_of_" #name, "get_array_of_" #old); \
    rb_define_alias(classMemory, "put_array_of_u" #name, "put_array_of_u" #old); \
    rb_define_alias(classMemory, "get_array_of_u" #name, "get_array_of_u" #old);
    
    ALIAS(char, int8);
    ALIAS(short, int16);
    ALIAS(int, int32);
    ALIAS(long_long, int64);
    
    rb_define_method(classMemory, "put_float32", memory_put_float32, 2);
    rb_define_method(classMemory, "get_float32", memory_get_float32, 1);
    rb_define_alias(classMemory, "put_float", "put_float32");
    rb_define_alias(classMemory, "get_float", "get_float32");
    rb_define_method(classMemory, "put_array_of_float32", memory_put_array_of_float32, 2);
    rb_define_method(classMemory, "get_array_of_float32", memory_get_array_of_float32, 2);
    rb_define_alias(classMemory, "put_array_of_float", "put_array_of_float32");
    rb_define_alias(classMemory, "get_array_of_float", "get_array_of_float32");
    rb_define_method(classMemory, "put_float64", memory_put_float64, 2);
    rb_define_method(classMemory, "get_float64", memory_get_float64, 1);
    rb_define_alias(classMemory, "put_double", "put_float64");
    rb_define_alias(classMemory, "get_double", "get_float64");
    rb_define_method(classMemory, "put_array_of_float64", memory_put_array_of_float64, 2);
    rb_define_method(classMemory, "get_array_of_float64", memory_get_array_of_float64, 2);
    rb_define_alias(classMemory, "put_array_of_double", "put_array_of_float64");
    rb_define_alias(classMemory, "get_array_of_double", "get_array_of_float64");
    rb_define_method(classMemory, "put_pointer", memory_put_pointer, 2);
    rb_define_method(classMemory, "get_pointer", memory_get_pointer, 1);
    rb_define_method(classMemory, "put_array_of_pointer", memory_put_array_of_pointer, 2);
    rb_define_method(classMemory, "get_array_of_pointer", memory_get_array_of_pointer, 2);
    rb_define_method(classMemory, "get_string", memory_get_string, -1);
    rb_define_method(classMemory, "put_string", memory_put_string, 2);
    rb_define_method(classMemory, "get_bytes", memory_get_bytes, 2);
    rb_define_method(classMemory, "put_bytes", memory_put_bytes, -1);
    rb_define_method(classMemory, "get_array_of_string", memory_get_array_of_string, -1);

    rb_define_method(classMemory, "clear", memory_clear, 0);
    rb_define_method(classMemory, "total", memory_size, 0);
    rb_define_alias(classMemory, "size", "total");
    rb_define_method(classMemory, "type_size", memory_type_size, 0);
    rb_define_method(classMemory, "[]", memory_aref, 1);

    id_to_ptr = rb_intern("to_ptr");
    id_call = rb_intern("call");
    id_plus = rb_intern("+");
}

