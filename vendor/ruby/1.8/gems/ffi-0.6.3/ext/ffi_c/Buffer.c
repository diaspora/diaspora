/*
 * Copyright (c) 2008, 2009, Wayne Meissner
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

#include <stdbool.h>
#include <stdint.h>
#include <limits.h>
#include <ruby.h>
#include "rbffi.h"
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
    buffer->memory.access = MEM_RD | MEM_WR;

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
    result->memory.access = ptr->memory.access;
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
    rb_define_method(BufferClass, "inspect", buffer_inspect, 0);
    rb_define_alias(BufferClass, "length", "total");
    rb_define_method(BufferClass, "+", buffer_plus, 1);
    rb_define_method(BufferClass, "slice", buffer_slice, 2);
}
