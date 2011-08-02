/*
 * Copyright (c) 2008-2010 Wayne Meissner
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

#include <stdbool.h>
#include <stdint.h>
#include <limits.h>
#include <ruby.h>
#include "rbffi.h"
#include "endian.h"
#include "AbstractMemory.h"

typedef struct Buffer {
    AbstractMemory memory;
    char* storage; /* start of malloc area */
    VALUE rbParent;
} Buffer;

static VALUE buffer_allocate(VALUE klass);
static VALUE buffer_initialize(int argc, VALUE* argv, VALUE self);
static void buffer_release(Buffer* ptr);
static void buffer_mark(Buffer* ptr);
static VALUE buffer_free(VALUE self);

static VALUE BufferClass = Qnil;

static VALUE
buffer_allocate(VALUE klass)
{
    Buffer* buffer;
    VALUE obj;

    obj = Data_Make_Struct(klass, Buffer, NULL, buffer_release, buffer);
    buffer->rbParent = Qnil;
    buffer->memory.flags = MEM_RD | MEM_WR;

    return obj;
}

static void
buffer_release(Buffer* ptr)
{
    if (ptr->storage != NULL) {
        xfree(ptr->storage);
        ptr->storage = NULL;
    }
    
    xfree(ptr);
}

static VALUE
buffer_initialize(int argc, VALUE* argv, VALUE self)
{
    VALUE rbSize = Qnil, rbCount = Qnil, rbClear = Qnil;
    Buffer* p;
    int nargs;

    Data_Get_Struct(self, Buffer, p);

    nargs = rb_scan_args(argc, argv, "12", &rbSize, &rbCount, &rbClear);
    p->memory.typeSize = rbffi_type_size(rbSize);
    p->memory.size = p->memory.typeSize * (nargs > 1 ? NUM2LONG(rbCount) : 1);

    p->storage = xmalloc(p->memory.size + 7);
    if (p->storage == NULL) {
        rb_raise(rb_eNoMemError, "Failed to allocate memory size=%lu bytes", p->memory.size);
        return Qnil;
    }

    /* ensure the memory is aligned on at least a 8 byte boundary */
    p->memory.address = (void *) (((uintptr_t) p->storage + 0x7) & (uintptr_t) ~0x7UL);
    
    if (nargs > 2 && (RTEST(rbClear) || rbClear == Qnil) && p->memory.size > 0) {
        memset(p->memory.address, 0, p->memory.size);
    }

    if (rb_block_given_p()) {
        return rb_ensure(rb_yield, self, buffer_free, self);
    }

    return self;
}

static VALUE
buffer_initialize_copy(VALUE self, VALUE other)
{
    AbstractMemory* src;
    Buffer* dst;
    
    Data_Get_Struct(self, Buffer, dst);
    src = rbffi_AbstractMemory_Cast(other, BufferClass);
    if (dst->storage != NULL) {
        xfree(dst->storage);
    }
    dst->storage = xmalloc(src->size + 7);
    if (dst->storage == NULL) {
        rb_raise(rb_eNoMemError, "failed to allocate memory size=%lu bytes", src->size);
        return Qnil;
    }
    
    dst->memory.address = (void *) (((uintptr_t) dst->storage + 0x7) & (uintptr_t) ~0x7UL);
    dst->memory.size = src->size;
    dst->memory.typeSize = src->typeSize;
    
    // finally, copy the actual buffer contents
    memcpy(dst->memory.address, src->address, src->size);

    return self;
}

static VALUE
buffer_alloc_inout(int argc, VALUE* argv, VALUE klass)
{
    return buffer_initialize(argc, argv, buffer_allocate(klass));
}

static VALUE
slice(VALUE self, long offset, long len)
{
    Buffer* ptr;
    Buffer* result;
    VALUE obj = Qnil;
    
    Data_Get_Struct(self, Buffer, ptr);
    checkBounds(&ptr->memory, offset, len);

    obj = Data_Make_Struct(BufferClass, Buffer, buffer_mark, -1, result);
    result->memory.address = ptr->memory.address + offset;
    result->memory.size = len;
    result->memory.flags = ptr->memory.flags;
    result->memory.typeSize = ptr->memory.typeSize;
    result->rbParent = self;

    return obj;
}

static VALUE
buffer_plus(VALUE self, VALUE rbOffset)
{
    Buffer* ptr;
    long offset = NUM2LONG(rbOffset);

    Data_Get_Struct(self, Buffer, ptr);

    return slice(self, offset, ptr->memory.size - offset);
}

static VALUE
buffer_slice(VALUE self, VALUE rbOffset, VALUE rbLength)
{
    return slice(self, NUM2LONG(rbOffset), NUM2LONG(rbLength));
}

static VALUE
buffer_inspect(VALUE self)
{
    char tmp[100];
    Buffer* ptr;

    Data_Get_Struct(self, Buffer, ptr);

    snprintf(tmp, sizeof(tmp), "#<FFI:Buffer:%p address=%p size=%ld>", ptr, ptr->memory.address, ptr->memory.size);
    
    return rb_str_new2(tmp);
}


#if BYTE_ORDER == LITTLE_ENDIAN
# define SWAPPED_ORDER BIG_ENDIAN
#else
# define SWAPPED_ORDER LITTLE_ENDIAN
#endif

static VALUE
buffer_order(int argc, VALUE* argv, VALUE self)
{
    Buffer* ptr;

    Data_Get_Struct(self, Buffer, ptr);
    if (argc == 0) {
        int order = (ptr->memory.flags & MEM_SWAP) == 0 ? BYTE_ORDER : SWAPPED_ORDER;
        return order == BIG_ENDIAN ? ID2SYM(rb_intern("big")) : ID2SYM(rb_intern("little"));
    } else {
        VALUE rbOrder = Qnil;
        int order = BYTE_ORDER;

        if (rb_scan_args(argc, argv, "1", &rbOrder) < 1) {
            rb_raise(rb_eArgError, "need byte order");
        }
        if (SYMBOL_P(rbOrder)) {
            ID id = SYM2ID(rbOrder);
            if (id == rb_intern("little")) {
                order = LITTLE_ENDIAN;

            } else if (id == rb_intern("big") || id == rb_intern("network")) {
                order = BIG_ENDIAN;
            }
        }
        if (order != BYTE_ORDER) {
            Buffer* p2;
            VALUE retval = slice(self, 0, ptr->memory.size);

            Data_Get_Struct(retval, Buffer, p2);
            p2->memory.flags |= MEM_SWAP;
            return retval;
        }

        return self;
    }
}

/* Only used to free the buffer if the yield in the initializer throws an exception */
static VALUE
buffer_free(VALUE self)
{
    Buffer* ptr;

    Data_Get_Struct(self, Buffer, ptr);
    if (ptr->storage != NULL) {
        xfree(ptr->storage);
        ptr->storage = NULL;
    }

    return self;
}

static void
buffer_mark(Buffer* ptr)
{
    rb_gc_mark(ptr->rbParent);
}

void
rbffi_Buffer_Init(VALUE moduleFFI)
{
    BufferClass = rb_define_class_under(moduleFFI, "Buffer", rbffi_AbstractMemoryClass);

    rb_global_variable(&BufferClass);
    rb_define_alloc_func(BufferClass, buffer_allocate);

    rb_define_singleton_method(BufferClass, "alloc_inout", buffer_alloc_inout, -1);
    rb_define_singleton_method(BufferClass, "alloc_out", buffer_alloc_inout, -1);
    rb_define_singleton_method(BufferClass, "alloc_in", buffer_alloc_inout, -1);
    rb_define_alias(rb_singleton_class(BufferClass), "new_in", "alloc_in");
    rb_define_alias(rb_singleton_class(BufferClass), "new_out", "alloc_out");
    rb_define_alias(rb_singleton_class(BufferClass), "new_inout", "alloc_inout");
    
    rb_define_method(BufferClass, "initialize", buffer_initialize, -1);
    rb_define_method(BufferClass, "initialize_copy", buffer_initialize_copy, 1);
    rb_define_method(BufferClass, "order", buffer_order, -1);
    rb_define_method(BufferClass, "inspect", buffer_inspect, 0);
    rb_define_alias(BufferClass, "length", "total");
    rb_define_method(BufferClass, "+", buffer_plus, 1);
    rb_define_method(BufferClass, "slice", buffer_slice, 2);
}

