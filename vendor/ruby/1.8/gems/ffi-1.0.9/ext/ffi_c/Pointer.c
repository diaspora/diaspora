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

#include <stdbool.h>
#include <stdint.h>
#include <limits.h>
#include <ruby.h>
#include "rbffi.h"
#include "endian.h"
#include "AbstractMemory.h"
#include "Pointer.h"

#define POINTER(obj) rbffi_AbstractMemory_Cast((obj), rbffi_PointerClass)

VALUE rbffi_PointerClass = Qnil;
VALUE rbffi_NullPointerSingleton = Qnil;

static void ptr_release(Pointer* ptr);
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
    p->memory.flags = (addr == NULL) ? 0 : (MEM_RD | MEM_WR);
    p->memory.typeSize = 1;
    p->rbParent = Qnil;

    return obj;
}

static VALUE
ptr_allocate(VALUE klass)
{
    Pointer* p;
    VALUE obj;

    obj = Data_Make_Struct(klass, Pointer, ptr_mark, ptr_release, p);
    p->rbParent = Qnil;
    p->memory.flags = MEM_RD | MEM_WR;

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
                p->memory.flags = 0;
            }
            break;

        default:
            if (rb_obj_is_kind_of(rbAddress, rbffi_PointerClass)) {
                Pointer* orig;

                p->rbParent = rbAddress;
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
ptr_initialize_copy(VALUE self, VALUE other)
{
    AbstractMemory* src;
    Pointer* dst;
    
    Data_Get_Struct(self, Pointer, dst);
    src = POINTER(other);
    if (src->size == LONG_MAX) {
        rb_raise(rb_eRuntimeError, "cannot duplicate unbounded memory area");
        return Qnil;
    }
    
    if ((dst->memory.flags & (MEM_RD | MEM_WR)) != (MEM_RD | MEM_WR)) {
        rb_raise(rb_eRuntimeError, "cannot duplicate unreadable/unwritable memory area");
        return Qnil;
    }

    if (dst->storage != NULL) {
        xfree(dst->storage);
        dst->storage = NULL;
    }

    dst->storage = xmalloc(src->size + 7);
    if (dst->storage == NULL) {
        rb_raise(rb_eNoMemError, "failed to allocate memory size=%lu bytes", src->size);
        return Qnil;
    }
    
    dst->allocated = true;
    dst->autorelease = true;
    dst->memory.address = (void *) (((uintptr_t) dst->storage + 0x7) & (uintptr_t) ~0x7UL);
    dst->memory.size = src->size;
    dst->memory.typeSize = src->typeSize;
    
    // finally, copy the actual memory contents
    memcpy(dst->memory.address, src->address, src->size);

    return self;
}

static VALUE
slice(VALUE self, long offset, long size)
{
    AbstractMemory* ptr;
    Pointer* p;
    VALUE retval;
    
    Data_Get_Struct(self, AbstractMemory, ptr);
    checkBounds(ptr, offset, size == LONG_MAX ? 1 : size);

    retval = Data_Make_Struct(rbffi_PointerClass, Pointer, ptr_mark, -1, p);

    p->memory.address = ptr->address + offset;
    p->memory.size = size;
    p->memory.flags = ptr->flags;
    p->memory.typeSize = ptr->typeSize;
    p->rbParent = self;

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
    char buf[100];
    Pointer* ptr;
    
    Data_Get_Struct(self, Pointer, ptr);

    if (ptr->memory.size != LONG_MAX) {
        snprintf(buf, sizeof(buf), "#<%s address=%p size=%lu>",
                rb_obj_classname(self), ptr->memory.address, ptr->memory.size);
    } else {
        snprintf(buf, sizeof(buf), "#<%s address=%p>", rb_obj_classname(self), ptr->memory.address);
    }

    return rb_str_new2(buf);
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

#if BYTE_ORDER == LITTLE_ENDIAN
# define SWAPPED_ORDER BIG_ENDIAN
#else
# define SWAPPED_ORDER LITTLE_ENDIAN
#endif

static VALUE
ptr_order(int argc, VALUE* argv, VALUE self)
{
    Pointer* ptr;

    Data_Get_Struct(self, Pointer, ptr);
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
            Pointer* p2;
            VALUE retval = slice(self, 0, ptr->memory.size);

            Data_Get_Struct(retval, Pointer, p2);
            p2->memory.flags |= MEM_SWAP;
            return retval;
        }

        return self;
    }
}


static VALUE
ptr_free(VALUE self)
{
    Pointer* ptr;

    Data_Get_Struct(self, Pointer, ptr);

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
ptr_autorelease(VALUE self, VALUE autorelease)
{
    Pointer* ptr;

    Data_Get_Struct(self, Pointer, ptr);
    ptr->autorelease = autorelease == Qtrue;

    return autorelease;
}

static VALUE
ptr_autorelease_p(VALUE self)
{
    Pointer* ptr;

    Data_Get_Struct(self, Pointer, ptr);
    
    return ptr->autorelease ? Qtrue : Qfalse;
}


static void
ptr_release(Pointer* ptr)
{
    if (ptr->autorelease && ptr->allocated && ptr->storage != NULL) {
        xfree(ptr->storage);
        ptr->storage = NULL;
    }
    xfree(ptr);
}

static void
ptr_mark(Pointer* ptr)
{
    rb_gc_mark(ptr->rbParent);
}

void
rbffi_Pointer_Init(VALUE moduleFFI)
{
    VALUE rbNullAddress = ULL2NUM(0);

    rbffi_PointerClass = rb_define_class_under(moduleFFI, "Pointer", rbffi_AbstractMemoryClass);
    rb_global_variable(&rbffi_PointerClass);

    rb_define_alloc_func(rbffi_PointerClass, ptr_allocate);
    rb_define_method(rbffi_PointerClass, "initialize", ptr_initialize, -1);
    rb_define_method(rbffi_PointerClass, "initialize_copy", ptr_initialize_copy, 1);
    rb_define_method(rbffi_PointerClass, "inspect", ptr_inspect, 0);
    rb_define_method(rbffi_PointerClass, "to_s", ptr_inspect, 0);
    rb_define_method(rbffi_PointerClass, "+", ptr_plus, 1);
    rb_define_method(rbffi_PointerClass, "slice", ptr_slice, 2);
    rb_define_method(rbffi_PointerClass, "null?", ptr_null_p, 0);
    rb_define_method(rbffi_PointerClass, "address", ptr_address, 0);
    rb_define_alias(rbffi_PointerClass, "to_i", "address");
    rb_define_method(rbffi_PointerClass, "==", ptr_equals, 1);
    rb_define_method(rbffi_PointerClass, "order", ptr_order, -1);
    rb_define_method(rbffi_PointerClass, "autorelease=", ptr_autorelease, 1);
    rb_define_method(rbffi_PointerClass, "autorelease?", ptr_autorelease_p, 0);
    rb_define_method(rbffi_PointerClass, "free", ptr_free, 0);

    rbffi_NullPointerSingleton = rb_class_new_instance(1, &rbNullAddress, rbffi_PointerClass);
    rb_define_const(rbffi_PointerClass, "NULL", rbffi_NullPointerSingleton);
}

