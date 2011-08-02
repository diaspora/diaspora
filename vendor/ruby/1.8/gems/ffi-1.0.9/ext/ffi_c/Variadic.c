/*
 * Copyright (c) 2008-2010 Wayne Meissner
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

#include <sys/param.h>
#include <sys/types.h>

#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include <ruby.h>

#include <ffi.h>
#include "rbffi.h"
#include "compat.h"

#include "AbstractMemory.h"
#include "Pointer.h"
#include "Types.h"
#include "Type.h"
#include "LastError.h"
#include "MethodHandle.h"
#include "Call.h"
#include "Thread.h"

typedef struct VariadicInvoker_ {
    VALUE rbAddress;
    VALUE rbReturnType;
    VALUE rbEnums;

    Type* returnType;
    ffi_abi abi;
    void* function;
    int paramCount;
} VariadicInvoker;


static VALUE variadic_allocate(VALUE klass);
static VALUE variadic_initialize(VALUE self, VALUE rbFunction, VALUE rbParameterTypes,
        VALUE rbReturnType, VALUE options);
static void variadic_mark(VariadicInvoker *);

static VALUE classVariadicInvoker = Qnil;


static VALUE
variadic_allocate(VALUE klass)
{
    VariadicInvoker *invoker;
    VALUE obj = Data_Make_Struct(klass, VariadicInvoker, variadic_mark, -1, invoker);

    invoker->rbAddress = Qnil;
    invoker->rbEnums = Qnil;
    invoker->rbReturnType = Qnil;

    return obj;
}

static void
variadic_mark(VariadicInvoker *invoker)
{
    rb_gc_mark(invoker->rbEnums);
    rb_gc_mark(invoker->rbAddress);
    rb_gc_mark(invoker->rbReturnType);
}

static VALUE
variadic_initialize(VALUE self, VALUE rbFunction, VALUE rbParameterTypes, VALUE rbReturnType, VALUE options)
{
    VariadicInvoker* invoker = NULL;
    VALUE retval = Qnil;
    VALUE convention = Qnil;
    VALUE fixed = Qnil;
    int i;

    Check_Type(options, T_HASH);
    convention = rb_hash_aref(options, ID2SYM(rb_intern("convention")));

    Data_Get_Struct(self, VariadicInvoker, invoker);
    invoker->rbEnums = rb_hash_aref(options, ID2SYM(rb_intern("enums")));
    invoker->rbAddress = rbFunction;
    invoker->function = rbffi_AbstractMemory_Cast(rbFunction, rbffi_PointerClass)->address;

#if defined(_WIN32) || defined(__WIN32__)
    VALUE rbConventionStr = rb_funcall2(convention, rb_intern("to_s"), 0, NULL);
    invoker->abi = (RTEST(convention) && strcmp(StringValueCStr(rbConventionStr), "stdcall") == 0)
            ? FFI_STDCALL : FFI_DEFAULT_ABI;
#else
    invoker->abi = FFI_DEFAULT_ABI;
#endif

    invoker->rbReturnType = rbffi_Type_Lookup(rbReturnType);
    if (!RTEST(invoker->rbReturnType)) {
        VALUE typeName = rb_funcall2(rbReturnType, rb_intern("inspect"), 0, NULL);
        rb_raise(rb_eTypeError, "Invalid return type (%s)", RSTRING_PTR(typeName));
    }

    Data_Get_Struct(rbReturnType, Type, invoker->returnType);

    invoker->paramCount = -1;

    fixed = rb_ary_new2(RARRAY_LEN(rbParameterTypes) - 1);
    for (i = 0; i < RARRAY_LEN(rbParameterTypes); ++i) {
        VALUE entry = rb_ary_entry(rbParameterTypes, i);
        VALUE rbType = rbffi_Type_Lookup(entry);
        Type* type;

        if (!RTEST(rbType)) {
            VALUE typeName = rb_funcall2(entry, rb_intern("inspect"), 0, NULL);
            rb_raise(rb_eTypeError, "Invalid parameter type (%s)", RSTRING_PTR(typeName));
        }
        Data_Get_Struct(rbType, Type, type);
        if (type->nativeType != NATIVE_VARARGS) {
            rb_ary_push(fixed, entry);
        }
    }
    /*
     * @fixed and @type_map are used by the parameter mangling ruby code
     */
    rb_iv_set(self, "@fixed", fixed);
    rb_iv_set(self, "@type_map", rb_hash_aref(options, ID2SYM(rb_intern("type_map"))));

    return retval;
}

static VALUE
variadic_invoke(VALUE self, VALUE parameterTypes, VALUE parameterValues)
{
    VariadicInvoker* invoker;
    FFIStorage* params;
    void* retval;
    ffi_cif cif;
    void** ffiValues;
    ffi_type** ffiParamTypes;
    ffi_type* ffiReturnType;
    Type** paramTypes;
    VALUE* argv;
    int paramCount = 0, i;
    ffi_status ffiStatus;
#ifndef HAVE_RUBY_THREAD_HAS_GVL_P
    rbffi_thread_t oldThread;
#endif
    Check_Type(parameterTypes, T_ARRAY);
    Check_Type(parameterValues, T_ARRAY);

    Data_Get_Struct(self, VariadicInvoker, invoker);
    paramCount = RARRAY_LEN(parameterTypes);
    paramTypes = ALLOCA_N(Type *, paramCount);
    ffiParamTypes = ALLOCA_N(ffi_type *, paramCount);
    params = ALLOCA_N(FFIStorage, paramCount);
    ffiValues = ALLOCA_N(void*, paramCount);
    argv = ALLOCA_N(VALUE, paramCount);
    retval = alloca(MAX(invoker->returnType->ffiType->size, FFI_SIZEOF_ARG));

    for (i = 0; i < paramCount; ++i) {
        VALUE rbType = rb_ary_entry(parameterTypes, i);
        
        if (!rb_obj_is_kind_of(rbType, rbffi_TypeClass)) {
            rb_raise(rb_eTypeError, "wrong type.  Expected (FFI::Type)");
        }
        Data_Get_Struct(rbType, Type, paramTypes[i]);

        switch (paramTypes[i]->nativeType) {
            case NATIVE_INT8:
            case NATIVE_INT16:
            case NATIVE_INT32:
                rbType = rb_const_get(rbffi_TypeClass, rb_intern("INT32"));
                Data_Get_Struct(rbType, Type, paramTypes[i]);
                break;
            case NATIVE_UINT8:
            case NATIVE_UINT16:
            case NATIVE_UINT32:
                rbType = rb_const_get(rbffi_TypeClass, rb_intern("UINT32"));
                Data_Get_Struct(rbType, Type, paramTypes[i]);
                break;
            
            case NATIVE_FLOAT32:
                rbType = rb_const_get(rbffi_TypeClass, rb_intern("DOUBLE"));
                Data_Get_Struct(rbType, Type, paramTypes[i]);
                break;

            default:
                break;
        }
        
        
        ffiParamTypes[i] = paramTypes[i]->ffiType;
        if (ffiParamTypes[i] == NULL) {
            rb_raise(rb_eArgError, "Invalid parameter type #%x", paramTypes[i]);
        }
        argv[i] = rb_ary_entry(parameterValues, i);
    }

    ffiReturnType = invoker->returnType->ffiType;
    if (ffiReturnType == NULL) {
        rb_raise(rb_eArgError, "Invalid return type");
    }
    ffiStatus = ffi_prep_cif(&cif, invoker->abi, paramCount, ffiReturnType, ffiParamTypes);
    switch (ffiStatus) {
        case FFI_BAD_ABI:
            rb_raise(rb_eArgError, "Invalid ABI specified");
        case FFI_BAD_TYPEDEF:
            rb_raise(rb_eArgError, "Invalid argument type specified");
        case FFI_OK:
            break;
        default:
            rb_raise(rb_eArgError, "Unknown FFI error");
    }

    rbffi_SetupCallParams(paramCount, argv, -1, paramTypes, params,
        ffiValues, NULL, 0, invoker->rbEnums);
#ifndef HAVE_RUBY_THREAD_HAS_GVL_P
    oldThread = rbffi_active_thread;
    rbffi_active_thread = rbffi_thread_self();
#endif

    ffi_call(&cif, FFI_FN(invoker->function), retval, ffiValues);

#ifndef HAVE_RUBY_THREAD_HAS_GVL_P
    rbffi_active_thread = oldThread;
#endif

    rbffi_save_errno();

    return rbffi_NativeValue_ToRuby(invoker->returnType, invoker->rbReturnType, retval);
}


void
rbffi_Variadic_Init(VALUE moduleFFI)
{
    classVariadicInvoker = rb_define_class_under(moduleFFI, "VariadicInvoker", rb_cObject);
    rb_global_variable(&classVariadicInvoker);

    rb_define_alloc_func(classVariadicInvoker, variadic_allocate);

    rb_define_method(classVariadicInvoker, "initialize", variadic_initialize, 4);
    rb_define_method(classVariadicInvoker, "invoke", variadic_invoke, 2);
}

