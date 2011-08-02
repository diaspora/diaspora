/*
 * Copyright (c) 2009, Wayne Meissner
 * Copyright (c) 2009, Luc Heinrich
 * Copyright (c) 2009, Aman Gupta.
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

#include <ruby.h>
#include "Pointer.h"
#include "rbffi.h"
#include "Function.h"
#include "StructByValue.h"
#include "Types.h"
#include "Struct.h"
#include "MappedType.h"
#include "MemoryPointer.h"

static ID id_from_native = 0;


VALUE
rbffi_NativeValue_ToRuby(Type* type, VALUE rbType, const void* ptr)
{
    switch (type->nativeType) {
        case NATIVE_VOID:
            return Qnil;
        case NATIVE_INT8:
          return INT2NUM((signed char) *(ffi_sarg *) ptr);
        case NATIVE_INT16:
          return INT2NUM((signed short) *(ffi_sarg *) ptr);
        case NATIVE_INT32:
          return INT2NUM((signed int) *(ffi_sarg *) ptr);
        case NATIVE_LONG:
            return LONG2NUM((signed long) *(ffi_sarg *) ptr);
        case NATIVE_INT64:
            return LL2NUM(*(signed long long *) ptr);

        case NATIVE_UINT8:
          return UINT2NUM((unsigned char) *(ffi_arg *) ptr);
        case NATIVE_UINT16:
          return UINT2NUM((unsigned short) *(ffi_arg *) ptr);
        case NATIVE_UINT32:
          return UINT2NUM((unsigned int) *(ffi_arg *) ptr);
        case NATIVE_ULONG:
            return ULONG2NUM((unsigned long) *(ffi_arg *) ptr);
        case NATIVE_UINT64:
            return ULL2NUM(*(unsigned long long *) ptr);

        case NATIVE_FLOAT32:
            return rb_float_new(*(float *) ptr);
        case NATIVE_FLOAT64:
            return rb_float_new(*(double *) ptr);
        case NATIVE_STRING:
            return (*(void **) ptr != NULL) ? rb_tainted_str_new2(*(char **) ptr) : Qnil;
        case NATIVE_POINTER:
            return rbffi_Pointer_NewInstance(*(void **) ptr);
        case NATIVE_BOOL:
            return ((unsigned char) *(ffi_arg *) ptr) ? Qtrue : Qfalse;
        
        case NATIVE_FUNCTION:
        case NATIVE_CALLBACK: {
            return *(void **) ptr != NULL 
                    ? rbffi_Function_NewInstance(rbType, rbffi_Pointer_NewInstance(*(void **) ptr))
                    : Qnil;
        }

        case NATIVE_STRUCT: {
            StructByValue* sbv = (StructByValue *)type;
            AbstractMemory* mem;
            VALUE rbMemory = rbffi_MemoryPointer_NewInstance(1, sbv->base.ffiType->size, false);

            Data_Get_Struct(rbMemory, AbstractMemory, mem);
            memcpy(mem->address, ptr, sbv->base.ffiType->size);

            return rb_class_new_instance(1, &rbMemory, sbv->rbStructClass);
        }

        case NATIVE_MAPPED: {
            // For mapped types, first convert to the real native type, then upcall to
            // ruby to convert to the expected return type
            MappedType* m = (MappedType *) type;
            VALUE values[2];

            values[0] = rbffi_NativeValue_ToRuby(m->type, m->rbType, ptr);
            values[1] = Qnil;

            return rb_funcall2(m->rbConverter, id_from_native, 2, values);
        }
    
        default:
            rb_raise(rb_eRuntimeError, "Unknown type: %d", type->nativeType);
            return Qnil;
    }
}

void
rbffi_Types_Init(VALUE moduleFFI)
{
    id_from_native = rb_intern("from_native");
}

