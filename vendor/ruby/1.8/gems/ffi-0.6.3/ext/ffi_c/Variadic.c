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
    NativeType* paramTypes;
    VALUE* argv;
    int paramCount = 0, i;
    ffi_status ffiStatus;

    Check_Type(parameterTypes, T_ARRAY);
    Check_Type(parameterValues, T_ARRAY);

    Data_Get_Struct(self, VariadicInvoker, invoker);
    paramCount = RARRAY_LEN(parameterTypes);
    paramTypes = ALLOCA_N(NativeType, paramCount);
    ffiParamTypes = ALLOCA_N(ffi_type *, paramCount);
    params = ALLOCA_N(FFIStorage, paramCount);
    ffiValues = ALLOCA_N(void*, paramCount);
    argv = ALLOCA_N(VALUE, paramCount);
    retval = alloca(MAX(invoker->returnType->ffiType->size, FFI_SIZEOF_ARG));

    for (i = 0; i < paramCount; ++i) {
        VALUE entry = rb_ary_entry(parameterTypes, i);
        int paramType = rbffi_Type_GetIntValue(entry);
        Type* type;
        Data_Get_Struct(entry, Type, type);

        switch (paramType) {
            case NATIVE_INT8:
            case NATIVE_INT16:
            case NATIVE_INT32:
            case NATIVE_ENUM:
                paramType = NATIVE_INT32;
                ffiParamTypes[i] = &ffi_type_sint;
                break;
            case NATIVE_UINT8:
            case NATIVE_UINT16:
            case NATIVE_UINT32:
                paramType = NATIVE_UINT32;
                ffiParamTypes[i] = &ffi_type_uint;
                break;
            case NATIVE_FLOAT32:
                paramType = NATIVE_FLOAT64;
                ffiParamTypes[i] = &ffi_type_double;
                break;
            default:
                ffiParamTypes[i] = type->ffiType;
                break;
        }
        paramTypes[i] = paramType;
        if (ffiParamTypes[i] == NULL) {
            rb_raise(rb_eArgError, "Invalid parameter type #%x", paramType);
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

    ffi_call(&cif, invoker->function, retval, ffiValues);

    rbffi_save_errno();

    return rbffi_NativeValue_ToRuby(invoker->returnType, invoker->rbReturnType, retval, invoker->rbEnums);
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

