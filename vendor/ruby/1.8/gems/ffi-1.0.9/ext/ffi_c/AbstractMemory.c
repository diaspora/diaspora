/*
 * Copyright (c) 2008, 2009, Wayne Meissner
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
#include <sys/param.h>
#include <stdint.h>
#include <stdbool.h>
#include <limits.h>
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
    memory->flags = MEM_RD | MEM_WR;

    return obj;
}
#define VAL(x, swap) (unlikely(((memory->flags & MEM_SWAP) != 0)) ? swap((x)) : (x))

#define NUM_OP(name, type, toNative, fromNative, swap) \
static void memory_op_put_##name(AbstractMemory* memory, long off, VALUE value); \
static void \
memory_op_put_##name(AbstractMemory* memory, long off, VALUE value) \
{ \
    type tmp = (type) VAL(toNative(value), swap); \
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
static VALUE memory_write_##name(VALUE self, VALUE value); \
static VALUE \
memory_write_##name(VALUE self, VALUE value) \
{ \
    AbstractMemory* memory; \
    Data_Get_Struct(self, AbstractMemory, memory); \
    memory_op_put_##name(memory, 0, value); \
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
    return fromNative(VAL(tmp, swap)); \
} \
static VALUE memory_get_##name(VALUE self, VALUE offset); \
static VALUE \
memory_get_##name(VALUE self, VALUE offset) \
{ \
    AbstractMemory* memory; \
    Data_Get_Struct(self, AbstractMemory, memory); \
    return memory_op_get_##name(memory, NUM2LONG(offset)); \
} \
static VALUE memory_read_##name(VALUE self); \
static VALUE \
memory_read_##name(VALUE self) \
{ \
    AbstractMemory* memory; \
    Data_Get_Struct(self, AbstractMemory, memory); \
    return memory_op_get_##name(memory, 0); \
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
        type tmp = (type) VAL(toNative(RARRAY_PTR(ary)[i]), swap); \
        memcpy(memory->address + off + (i * sizeof(type)), &tmp, sizeof(tmp)); \
    } \
    return self; \
} \
static VALUE memory_write_array_of_##name(VALUE self, VALUE ary); \
static VALUE \
memory_write_array_of_##name(VALUE self, VALUE ary) \
{ \
    return memory_put_array_of_##name(self, INT2FIX(0), ary); \
} \
static VALUE memory_get_array_of_##name(VALUE self, VALUE offset, VALUE length); \
static VALUE \
memory_get_array_of_##name(VALUE self, VALUE offset, VALUE length) \
{ \
    long count = NUM2LONG(length); \
    long off = NUM2LONG(offset); \
    AbstractMemory* memory = MEMORY(self); \
    VALUE retVal = rb_ary_new2(count); \
    long i; \
    checkRead(memory); \
    checkBounds(memory, off, count * sizeof(type)); \
    for (i = 0; i < count; ++i) { \
        type tmp; \
        memcpy(&tmp, memory->address + off + (i * sizeof(type)), sizeof(tmp)); \
        rb_ary_push(retVal, fromNative(VAL(tmp, swap))); \
    } \
    return retVal; \
} \
static VALUE memory_read_array_of_##name(VALUE self, VALUE length); \
static VALUE \
memory_read_array_of_##name(VALUE self, VALUE length) \
{ \
    return memory_get_array_of_##name(self, INT2FIX(0), length); \
}

#define NOSWAP(x) (x)
#define bswap16(x) (((x) >> 8) & 0xff) | (((x) << 8) & 0xff00);
static inline int16_t
SWAPS16(int16_t x)
{
    return bswap16(x);
}

static inline uint16_t
SWAPU16(uint16_t x)
{
    return bswap16(x);
}

#if !defined(__GNUC__) || (__GNUC__ < 4) || (__GNUC__ == 4 && __GNUC_MINOR__ < 3)
#define bswap32(x) \
       (((x << 24) & 0xff000000) | \
        ((x <<  8) & 0x00ff0000) | \
        ((x >>  8) & 0x0000ff00) | \
        ((x >> 24) & 0x000000ff))

#define bswap64(x) \
       (((x << 56) & 0xff00000000000000ULL) | \
        ((x << 40) & 0x00ff000000000000ULL) | \
        ((x << 24) & 0x0000ff0000000000ULL) | \
        ((x <<  8) & 0x000000ff00000000ULL) | \
        ((x >>  8) & 0x00000000ff000000ULL) | \
        ((x >> 24) & 0x0000000000ff0000ULL) | \
        ((x >> 40) & 0x000000000000ff00ULL) | \
        ((x >> 56) & 0x00000000000000ffULL))

static inline int32_t 
SWAPS32(int32_t x)
{
    return bswap32(x);
}

static inline uint32_t 
SWAPU32(uint32_t x)
{
    return bswap32(x);
}

static inline int64_t
SWAPS64(int64_t x)
{
    return bswap64(x);
}

static inline uint64_t
SWAPU64(uint64_t x)
{
    return bswap64(x);
}

#else
# define SWAPS32(x) ((int32_t) __builtin_bswap32(x))
# define SWAPU32(x) ((uint32_t) __builtin_bswap32(x))
# define SWAPS64(x) ((int64_t) __builtin_bswap64(x))
# define SWAPU64(x) ((uint64_t) __builtin_bswap64(x))
#endif

#if LONG_MAX > INT_MAX
# define SWAPSLONG SWAPS64
# define SWAPULONG SWAPU64
#else
# define SWAPSLONG SWAPS32
# define SWAPULONG SWAPU32
#endif

NUM_OP(int8, int8_t, NUM2INT, INT2NUM, NOSWAP);
NUM_OP(uint8, uint8_t, NUM2UINT, UINT2NUM, NOSWAP);
NUM_OP(int16, int16_t, NUM2INT, INT2NUM, SWAPS16);
NUM_OP(uint16, uint16_t, NUM2UINT, UINT2NUM, SWAPU16);
NUM_OP(int32, int32_t, NUM2INT, INT2NUM, SWAPS32);
NUM_OP(uint32, uint32_t, NUM2UINT, UINT2NUM, SWAPU32);
NUM_OP(int64, int64_t, NUM2LL, LL2NUM, SWAPS64);
NUM_OP(uint64, uint64_t, NUM2ULL, ULL2NUM, SWAPU64);
NUM_OP(long, long, NUM2LONG, LONG2NUM, SWAPSLONG);
NUM_OP(ulong, unsigned long, NUM2ULONG, ULONG2NUM, SWAPULONG);
NUM_OP(float32, float, NUM2DBL, rb_float_new, NOSWAP);
NUM_OP(float64, double, NUM2DBL, rb_float_new, NOSWAP);

static inline void*
get_pointer_value(VALUE value)
{
    const int type = TYPE(value);
    if (type == T_DATA && rb_obj_is_kind_of(value, rbffi_PointerClass)) {
        return memory_address(value);
    } else if (type == T_NIL) {
        return NULL;
    } else if (type == T_FIXNUM) {
        return (void *) (uintptr_t) FIX2ULONG(value);
    } else if (type == T_BIGNUM) {
        return (void *) (uintptr_t) NUM2ULL(value);
    } else if (rb_respond_to(value, id_to_ptr)) {
        return MEMORY_PTR(rb_funcall2(value, id_to_ptr, 0, NULL));
    } else {
        rb_raise(rb_eArgError, "value is not a pointer");
        return NULL;
    }
}

NUM_OP(pointer, void *, get_pointer_value, rbffi_Pointer_NewInstance, NOSWAP);

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
memory_read_array_of_string(int argc, VALUE* argv, VALUE self)
{
    VALUE* rargv = ALLOCA_N(VALUE, argc + 1);
    int i;

    rargv[0] = INT2FIX(0);
    for (i = 0; i < argc; i++) {
        rargv[i + 1] = argv[i];
    }

    return memory_get_array_of_string(argc + 1, rargv, self);
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
memory_read_bytes(VALUE self, VALUE length)
{
    return memory_get_bytes(self, INT2FIX(0), length);
}

static VALUE 
memory_write_bytes(int argc, VALUE* argv, VALUE self)
{
    VALUE* wargv = ALLOCA_N(VALUE, argc + 1);
    int i;

    wargv[0] = INT2FIX(0);
    for (i = 0; i < argc; i++) {
        wargv[i + 1] = argv[i];
    }

    return memory_put_bytes(argc + 1, wargv, self);
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
    .uslong = &memory_op_ulong,
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
    rb_define_method(classMemory, "write_" #type, memory_write_##type, 1); \
    rb_define_method(classMemory, "read_" #type, memory_read_##type, 0); \
    rb_define_method(classMemory, "write_u" #type, memory_write_u##type, 1); \
    rb_define_method(classMemory, "read_u" #type, memory_read_u##type, 0); \
    rb_define_method(classMemory, "put_array_of_" #type, memory_put_array_of_##type, 2); \
    rb_define_method(classMemory, "get_array_of_" #type, memory_get_array_of_##type, 2); \
    rb_define_method(classMemory, "put_array_of_u" #type, memory_put_array_of_u##type, 2); \
    rb_define_method(classMemory, "get_array_of_u" #type, memory_get_array_of_u##type, 2); \
    rb_define_method(classMemory, "write_array_of_" #type, memory_write_array_of_##type, 1); \
    rb_define_method(classMemory, "read_array_of_" #type, memory_read_array_of_##type, 1); \
    rb_define_method(classMemory, "write_array_of_u" #type, memory_write_array_of_u##type, 1); \
    rb_define_method(classMemory, "read_array_of_u" #type, memory_read_array_of_u##type, 1);
    
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
    rb_define_alias(classMemory, "write_" #name, "write_" #old); \
    rb_define_alias(classMemory, "read_" #name, "read_" #old); \
    rb_define_alias(classMemory, "write_u" #name, "write_u" #old); \
    rb_define_alias(classMemory, "read_u" #name, "read_u" #old); \
    rb_define_alias(classMemory, "put_array_of_" #name, "put_array_of_" #old); \
    rb_define_alias(classMemory, "get_array_of_" #name, "get_array_of_" #old); \
    rb_define_alias(classMemory, "put_array_of_u" #name, "put_array_of_u" #old); \
    rb_define_alias(classMemory, "get_array_of_u" #name, "get_array_of_u" #old); \
    rb_define_alias(classMemory, "write_array_of_" #name, "write_array_of_" #old); \
    rb_define_alias(classMemory, "read_array_of_" #name, "read_array_of_" #old); \
    rb_define_alias(classMemory, "write_array_of_u" #name, "write_array_of_u" #old); \
    rb_define_alias(classMemory, "read_array_of_u" #name, "read_array_of_u" #old);
    
    ALIAS(char, int8);
    ALIAS(short, int16);
    ALIAS(int, int32);
    ALIAS(long_long, int64);
    
    rb_define_method(classMemory, "put_float32", memory_put_float32, 2);
    rb_define_method(classMemory, "get_float32", memory_get_float32, 1);
    rb_define_alias(classMemory, "put_float", "put_float32");
    rb_define_alias(classMemory, "get_float", "get_float32");
    rb_define_method(classMemory, "write_float", memory_write_float32, 1);
    rb_define_method(classMemory, "read_float", memory_read_float32, 0);
    rb_define_method(classMemory, "put_array_of_float32", memory_put_array_of_float32, 2);
    rb_define_method(classMemory, "get_array_of_float32", memory_get_array_of_float32, 2);
    rb_define_method(classMemory, "write_array_of_float", memory_write_array_of_float32, 1);
    rb_define_method(classMemory, "read_array_of_float", memory_read_array_of_float32, 1);
    rb_define_alias(classMemory, "put_array_of_float", "put_array_of_float32");
    rb_define_alias(classMemory, "get_array_of_float", "get_array_of_float32");
    rb_define_method(classMemory, "put_float64", memory_put_float64, 2);
    rb_define_method(classMemory, "get_float64", memory_get_float64, 1);
    rb_define_alias(classMemory, "put_double", "put_float64");
    rb_define_alias(classMemory, "get_double", "get_float64");
    rb_define_method(classMemory, "write_double", memory_write_float64, 1);
    rb_define_method(classMemory, "read_double", memory_read_float64, 0);
    rb_define_method(classMemory, "put_array_of_float64", memory_put_array_of_float64, 2);
    rb_define_method(classMemory, "get_array_of_float64", memory_get_array_of_float64, 2);
    rb_define_method(classMemory, "write_array_of_double", memory_write_array_of_float64, 1);
    rb_define_method(classMemory, "read_array_of_double", memory_read_array_of_float64, 1);
    rb_define_alias(classMemory, "put_array_of_double", "put_array_of_float64");
    rb_define_alias(classMemory, "get_array_of_double", "get_array_of_float64");
    rb_define_method(classMemory, "put_pointer", memory_put_pointer, 2);
    rb_define_method(classMemory, "get_pointer", memory_get_pointer, 1);
    rb_define_method(classMemory, "write_pointer", memory_write_pointer, 1);
    rb_define_method(classMemory, "read_pointer", memory_read_pointer, 0);
    rb_define_method(classMemory, "put_array_of_pointer", memory_put_array_of_pointer, 2);
    rb_define_method(classMemory, "get_array_of_pointer", memory_get_array_of_pointer, 2);
    rb_define_method(classMemory, "write_array_of_pointer", memory_write_array_of_pointer, 1);
    rb_define_method(classMemory, "read_array_of_pointer", memory_read_array_of_pointer, 1);

    rb_define_method(classMemory, "get_string", memory_get_string, -1);
    rb_define_method(classMemory, "put_string", memory_put_string, 2);
    rb_define_method(classMemory, "get_bytes", memory_get_bytes, 2);
    rb_define_method(classMemory, "put_bytes", memory_put_bytes, -1);
    rb_define_method(classMemory, "read_bytes", memory_read_bytes, 1);
    rb_define_method(classMemory, "write_bytes", memory_write_bytes, -1);
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

