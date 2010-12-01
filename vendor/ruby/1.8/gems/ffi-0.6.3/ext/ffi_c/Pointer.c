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

#include <stdbool.h>
#include <stdint.h>
#include <limits.h>
#include <ruby.h>
#include "rbffi.h"
#include "AbstractMemory.h"
#include "Pointer.h"

typedef struct Pointer {
    AbstractMemory memory;
    VALUE parent;
} Pointer;

#define POINTER(obj) rbffi_AbstractMemory_Cast((obj), rbffi_PointerClass)

VALUE rbffi_PointerClass = Qnil;
VALUE rbffi_NullPointerSingleton = Qnil;

static void ptr_mark(Pointer* ptr);

VALUE
rbffi_Pointer_NewInstance(void* addr)
{
    Pointer* p;
    VALUE obj;

    if (addr == NULL) {
        return rbffi_NullPointerSingleton;
    }

    obj = Data_Make_Struct(rbffi_PointerClass, Pointer, NULL, -1, p);
    p->memory.address = addr;
    p->memory.size = LONG_MAX;
    p->memory.access = (addr == NULL) ? 0 : (MEM_RD | MEM_WR);
    p->memory.typeSize = 1;
    p->parent = Qnil;

    return obj;
}

static VALUE
ptr_allocate(VALUE klass)
{
    Pointer* p;
    VALUE obj;

    obj = Data_Make_Struct(klass, Pointer, NULL, -1, p);
    p->parent = Qnil;
    p->memory.access = MEM_RD | MEM_WR;

    return obj;
}

static VALUE
ptr_initialize(int argc, VALUE* argv, VALUE self)
{
    Pointer* p;
    VALUE rbType = Qnil, rbAddress = Qnil;
    int typeSize = 1;

    Data_Get_Struct(self, Pointer, p);

    switch (rb_scan_args(argc, argv, "11", &rbType, &rbAddress)) {
        case 1:
            rbAddress = rbType;
            typeSize = 1;
            break;
        case 2:
            typeSize = rbffi_type_size(rbType);
            break;
        default:
            rb_raise(rb_eArgError, "Invalid arguments");
    }

    switch (TYPE(rbAddress)) {
        case T_FIXNUM:
        case T_BIGNUM:
            p->memory.address = (void*) (uintptr_t) NUM2LL(rbAddress);
            p->memory.size = LONG_MAX;
            if (p->memory.address == NULL) {
                p->memory.access = 0;
            }
            break;

        default:
            if (rb_obj_is_kind_of(rbAddress, rbffi_PointerClass)) {
                Pointer* orig;

                p->parent = rbAddress;
                Data_Get_Struct(rbAddress, Pointer, orig);
                p->memory = orig->memory;
            } else {
                rb_raise(rb_eTypeError, "wrong argument type, expected Integer or FFI::Pointer");
            }
            break;
    }

    p->memory.typeSize = typeSize;

    return self;
}


static VALUE
slice(VALUE self, long offset, long size)
{
    AbstractMemory* ptr;
    Pointer* p;
    VALUE retval;
    
    Data_Get_Struct(self, AbstractMemory, ptr);
    checkBounds(ptr, offset, 1);

    retval = Data_Make_Struct(rbffi_PointerClass, Pointer, ptr_mark, -1, p);

    p->memory.address = ptr->address + offset;
    p->memory.size = size;
    p->memory.access = ptr->access;
    p->memory.typeSize = ptr->typeSize;
    p->parent = self;

    return retval;
}

static VALUE
ptr_plus(VALUE self, VALUE offset)
{
    AbstractMemory* ptr;
    long off = NUM2LONG(offset);

    Data_Get_Struct(self, AbstractMemory, ptr);

    return slice(self, off, ptr->size == LONG_MAX ? LONG_MAX : ptr->size - off);
}

static VALUE
ptr_slice(VALUE self, VALUE rbOffset, VALUE rbLength)
{
    return slice(self, NUM2LONG(rbOffset), NUM2LONG(rbLength));
}

static VALUE
ptr_inspect(VALUE self)
{
    Pointer* ptr;
    char tmp[100];

    Data_Get_Struct(self, Pointer, ptr);
    snprintf(tmp, sizeof(tmp), "#<FFI::Pointer address=%p>", ptr->memory.address);

    return rb_str_new2(tmp);
}

static VALUE
ptr_null_p(VALUE self)
{
    Pointer* ptr;

    Data_Get_Struct(self, Pointer, ptr);

    return ptr->memory.address == NULL ? Qtrue : Qfalse;
}

static VALUE
ptr_equals(VALUE self, VALUE other)
{
    Pointer* ptr;
    
    Data_Get_Struct(self, Pointer, ptr);

    return ptr->memory.address == POINTER(other)->address ? Qtrue : Qfalse;
}

static VALUE
ptr_address(VALUE self)
{
    Pointer* ptr;
    
    Data_Get_Struct(self, Pointer, ptr);

    return ULL2NUM((uintptr_t) ptr->memory.address);
}

static void
ptr_mark(Pointer* ptr)
{
    rb_gc_mark(ptr->parent);
}

void
rbffi_Pointer_Init(VALUE moduleFFI)
{
    VALUE rbNullAddress = ULL2NUM(0);

    rbffi_PointerClass = rb_define_class_under(moduleFFI, "Pointer", rbffi_AbstractMemoryClass);
    rb_global_variable(&rbffi_PointerClass);

    rb_define_alloc_func(rbffi_PointerClass, ptr_allocate);
    rb_define_method(rbffi_PointerClass, "initialize", ptr_initialize, -1);
    rb_define_method(rbffi_PointerClass, "inspect", ptr_inspect, 0);
    rb_define_method(rbffi_PointerClass, "+", ptr_plus, 1);
    rb_define_method(rbffi_PointerClass, "slice", ptr_slice, 2);
    rb_define_method(rbffi_PointerClass, "null?", ptr_null_p, 0);
    rb_define_method(rbffi_PointerClass, "address", ptr_address, 0);
    rb_define_alias(rbffi_PointerClass, "to_i", "address");
    rb_define_method(rbffi_PointerClass, "==", ptr_equals, 1);

    rbffi_NullPointerSingleton = rb_class_new_instance(1, &rbNullAddress, rbffi_PointerClass);
    rb_define_const(rbffi_PointerClass, "NULL", rbffi_NullPointerSingleton);
}
