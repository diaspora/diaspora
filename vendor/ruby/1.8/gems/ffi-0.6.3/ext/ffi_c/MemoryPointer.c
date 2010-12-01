/*
 * Copyright (c) 2008, 2009, Wayne Meissner
 * Copyright (c) 2008, Luc Heinrich <luc@honk-honk.com>
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

#include <stdbool.h>
#include <stdint.h>
#include <limits.h>
#include <ruby.h>
#include "rbffi.h"
#include "AbstractMemory.h"
#include "Pointer.h"
#include "MemoryPointer.h"

typedef struct MemoryPointer {
    AbstractMemory memory;
    char* storage; /* start of malloc area */
    bool autorelease;
    bool allocated;
} MemoryPointer;

static VALUE memptr_allocate(VALUE klass);
static void memptr_release(MemoryPointer* ptr);
static VALUE memptr_malloc(VALUE self, long size, long count, bool clear);
static VALUE memptr_free(VALUE self);

VALUE rbffi_MemoryPointerClass;

#define MEMPTR(obj) ((MemoryPointer *) rbffi_AbstractMemory_Cast(obj, rbffi_MemoryPointerClass))

VALUE
rbffi_MemoryPointer_NewInstance(long size, long count, bool clear)
{
    return memptr_malloc(memptr_allocate(rbffi_MemoryPointerClass), size, count, clear);
}

static VALUE
memptr_allocate(VALUE klass)
{
    MemoryPointer* p;
    VALUE obj = Data_Make_Struct(klass, MemoryPointer, NULL, memptr_release, p);
    p->memory.access = MEM_RD | MEM_WR;

    return obj;
}

static VALUE
memptr_initialize(int argc, VALUE* argv, VALUE self)
{
    VALUE size = Qnil, count = Qnil, clear = Qnil;
    int nargs = rb_scan_args(argc, argv, "12", &size, &count, &clear);

    memptr_malloc(self, rbffi_type_size(size), nargs > 1 ? NUM2LONG(count) : 1,
        RTEST(clear) || clear == Qnil);
    
    if (rb_block_given_p()) {
        return rb_ensure(rb_yield, self, memptr_free, self);
    }

    return self;
}

static VALUE
memptr_malloc(VALUE self, long size, long count, bool clear)
{
    MemoryPointer* p;
    unsigned long msize;

    Data_Get_Struct(self, MemoryPointer, p);

    msize = size * count;

    p->storage = xmalloc(msize + 7);
    if (p->storage == NULL) {
        rb_raise(rb_eNoMemError, "Failed to allocate memory size=%ld bytes", msize);
        return Qnil;
    }
    p->autorelease = true;
    p->memory.typeSize = size;
    p->memory.size = msize;
    /* ensure the memory is aligned on at least a 8 byte boundary */
    p->memory.address = (char *) (((uintptr_t) p->storage + 0x7) & (uintptr_t) ~0x7UL);;
    p->allocated = true;
    
    if (clear && p->memory.size > 0) {
        memset(p->memory.address, 0, p->memory.size);
    }

    return self;
}

static VALUE
memptr_inspect(VALUE self)
{
    MemoryPointer* ptr;
    char tmp[100];

    Data_Get_Struct(self, MemoryPointer, ptr);

    snprintf(tmp, sizeof(tmp), "#<FFI::MemoryPointer address=%p size=%lu>", ptr->memory.address, ptr->memory.size);
    return rb_str_new2(tmp);
}

static VALUE
memptr_free(VALUE self)
{
    MemoryPointer* ptr;

    Data_Get_Struct(self, MemoryPointer, ptr);

    if (ptr->allocated) {
        if (ptr->storage != NULL) {
            xfree(ptr->storage);
            ptr->storage = NULL;
        }
        ptr->allocated = false;
    }

    return self;
}

static VALUE
memptr_autorelease(VALUE self, VALUE autorelease)
{
    MemoryPointer* ptr;

    Data_Get_Struct(self, MemoryPointer, ptr);
    ptr->autorelease = autorelease == Qtrue;

    return autorelease;
}

static void
memptr_release(MemoryPointer* ptr)
{
    if (ptr->autorelease && ptr->allocated && ptr->storage != NULL) {
        xfree(ptr->storage);
        ptr->storage = NULL;
    }
    xfree(ptr);
}

void
rbffi_MemoryPointer_Init(VALUE moduleFFI)
{
    rbffi_MemoryPointerClass = rb_define_class_under(moduleFFI, "MemoryPointer", rbffi_PointerClass);
    rb_global_variable(&rbffi_MemoryPointerClass);

    rb_define_alloc_func(rbffi_MemoryPointerClass, memptr_allocate);
    rb_define_method(rbffi_MemoryPointerClass, "initialize", memptr_initialize, -1);
    rb_define_method(rbffi_MemoryPointerClass, "inspect", memptr_inspect, 0);
    rb_define_method(rbffi_MemoryPointerClass, "autorelease=", memptr_autorelease, 1);
    rb_define_method(rbffi_MemoryPointerClass, "free", memptr_free, 0);
}
