/*
 * Copyright (c) 2009, Wayne Meissner
 * Copyright (c) 2009, Luc Heinrich <luc@honk-honk.com>
 * Copyright (c) 2009, Mike Dalessio <mike.dalessio@gmail.com>
 * Copyright (c) 2009, Aman Gupta.
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
#include <errno.h>
#include <ruby.h>
#if defined(HAVE_NATIVETHREAD) && defined(HAVE_RB_THREAD_BLOCKING_REGION) && !defined(_WIN32)
#  include <signal.h>
#  include <pthread.h>
#endif
#include <ffi.h>
#include "extconf.h"
#include "rbffi.h"
#include "compat.h"
#include "AbstractMemory.h"
#include "Pointer.h"
#include "Struct.h"
#include "Function.h"
#include "Type.h"
#include "LastError.h"
#include "Call.h"
#include "MappedType.h"
#include "Thread.h"

#ifdef USE_RAW
#  ifndef __i386__
#    error "RAW argument packing only supported on i386"
#  endif

#define INT8_ADJ (4)
#define INT16_ADJ (4)
#define INT32_ADJ (4)
#define INT64_ADJ (8)
#define LONG_ADJ (sizeof(long))
#define FLOAT32_ADJ (4)
#define FLOAT64_ADJ (8)
#define ADDRESS_ADJ (sizeof(void *))

#endif /* USE_RAW */

#ifdef USE_RAW
#  define ADJ(p, a) ((p) = (FFIStorage*) (((char *) p) + a##_ADJ))
#else
#  define ADJ(p, a) (++(p))
#endif

static void* callback_param(VALUE proc, VALUE cbinfo);
static inline void* getPointer(VALUE value, int type);
static inline char* getString(VALUE value, int type);

static ID id_to_ptr, id_map_symbol, id_to_native;

void
rbffi_SetupCallParams(int argc, VALUE* argv, int paramCount, Type** paramTypes,
        FFIStorage* paramStorage, void** ffiValues,
        VALUE* callbackParameters, int callbackCount, VALUE enums)
{
    VALUE callbackProc = Qnil;
    FFIStorage* param = &paramStorage[0];
    int i, argidx, cbidx, argCount;

    if (unlikely(paramCount != -1 && paramCount != argc)) {
        if (argc == (paramCount - 1) && callbackCount == 1 && rb_block_given_p()) {
            callbackProc = rb_block_proc();
        } else {
            rb_raise(rb_eArgError, "wrong number of arguments (%d for %d)", argc, paramCount);
        }
    }

    argCount = paramCount != -1 ? paramCount : argc;

    for (i = 0, argidx = 0, cbidx = 0; i < argCount; ++i) {
        Type* paramType = paramTypes[i];
        int type;

        
        if (unlikely(paramType->nativeType == NATIVE_MAPPED)) {
            VALUE values[] = { argv[argidx], Qnil };
            argv[argidx] = rb_funcall2(((MappedType *) paramType)->rbConverter, id_to_native, 2, values);
            paramType = ((MappedType *) paramType)->type;
        }

        type = argidx < argc ? TYPE(argv[argidx]) : T_NONE;
        ffiValues[i] = param;

        switch (paramType->nativeType) {

            case NATIVE_INT8:
                param->s8 = NUM2INT(argv[argidx]);
                ++argidx;
                ADJ(param, INT8);
                break;


            case NATIVE_INT16:
                param->s16 = NUM2INT(argv[argidx]);
                ++argidx;
                ADJ(param, INT16);
                break;


            case NATIVE_INT32:
                if (unlikely(type == T_SYMBOL && enums != Qnil)) {
                    VALUE value = rb_funcall(enums, id_map_symbol, 1, argv[argidx]);
                    param->s32 = NUM2INT(value);

                } else {
                    param->s32 = NUM2INT(argv[argidx]);
                }

                ++argidx;
                ADJ(param, INT32);
                break;


            case NATIVE_BOOL:
                if (type != T_TRUE && type != T_FALSE) {
                    rb_raise(rb_eTypeError, "wrong argument type  (expected a boolean parameter)");
                }
                param->s8 = argv[argidx++] == Qtrue;
                ADJ(param, INT8);
                break;


            case NATIVE_UINT8:
                param->u8 = NUM2UINT(argv[argidx]);
                ADJ(param, INT8);
                ++argidx;
                break;


            case NATIVE_UINT16:
                param->u16 = NUM2UINT(argv[argidx]);
                ADJ(param, INT16);
                ++argidx;
                break;


            case NATIVE_UINT32:
                param->u32 = NUM2UINT(argv[argidx]);
                ADJ(param, INT32);
                ++argidx;
                break;


            case NATIVE_INT64:
                param->i64 = NUM2LL(argv[argidx]);
                ADJ(param, INT64);
                ++argidx;
                break;


            case NATIVE_UINT64:
                param->u64 = NUM2ULL(argv[argidx]);
                ADJ(param, INT64);
                ++argidx;
                break;

            case NATIVE_LONG:
                *(ffi_sarg *) param = NUM2LONG(argv[argidx]);
                ADJ(param, LONG);
                ++argidx;
                break;

            case NATIVE_ULONG:
                *(ffi_arg *) param = NUM2ULONG(argv[argidx]);
                ADJ(param, LONG);
                ++argidx;
                break;

            case NATIVE_FLOAT32:
                param->f32 = (float) NUM2DBL(argv[argidx]);
                ADJ(param, FLOAT32);
                ++argidx;
                break;

            case NATIVE_FLOAT64:
                param->f64 = NUM2DBL(argv[argidx]);
                ADJ(param, FLOAT64);
                ++argidx;
                break;


            case NATIVE_STRING:
                param->ptr = getString(argv[argidx++], type);
                ADJ(param, ADDRESS);
                break;

            case NATIVE_POINTER:
            case NATIVE_BUFFER_IN:
            case NATIVE_BUFFER_OUT:
            case NATIVE_BUFFER_INOUT:
                param->ptr = getPointer(argv[argidx++], type);
                ADJ(param, ADDRESS);
                break;


            case NATIVE_FUNCTION:
            case NATIVE_CALLBACK:
                if (callbackProc != Qnil) {
                    param->ptr = callback_param(callbackProc, callbackParameters[cbidx++]);
                } else {
                    param->ptr = callback_param(argv[argidx], callbackParameters[cbidx++]);
                    ++argidx;
                }
                ADJ(param, ADDRESS);
                break;

            case NATIVE_STRUCT:
                ffiValues[i] = getPointer(argv[argidx++], type);
                break;

            default:
                rb_raise(rb_eArgError, "Invalid parameter type: %d", paramType->nativeType);
        }
    }
}


typedef struct BlockingCall_ {
    void* function;
    FunctionType* info;
    void **ffiValues;
    void* retval;
    void* stkretval;
    void* params;
} BlockingCall;

static VALUE
call_blocking_function(void* data)
{
    BlockingCall* b = (BlockingCall *) data;

    ffi_call(&b->info->ffi_cif, FFI_FN(b->function), b->retval, b->ffiValues);

    return Qnil;
}

static VALUE
do_blocking_call(void *data)
{
    rbffi_thread_blocking_region(call_blocking_function, data, (void *) -1, NULL);

    return Qnil;
}

static VALUE
cleanup_blocking_call(void *data)
{
    BlockingCall* bc = (BlockingCall *) data;

    memcpy(bc->stkretval, bc->retval, MAX(bc->info->ffi_cif.rtype->size, FFI_SIZEOF_ARG));
    xfree(bc->params);
    xfree(bc->ffiValues);
    xfree(bc->retval);
    xfree(bc);

    return Qnil;
}

VALUE
rbffi_CallFunction(int argc, VALUE* argv, void* function, FunctionType* fnInfo)
{
    void* retval;
    void** ffiValues;
    FFIStorage* params;
    VALUE rbReturnValue;

#if !defined(HAVE_RUBY_THREAD_HAS_GVL_P)
    rbffi_thread_t oldThread;
#endif

    retval = alloca(MAX(fnInfo->ffi_cif.rtype->size, FFI_SIZEOF_ARG));
    
    if (unlikely(fnInfo->blocking)) {
        BlockingCall* bc;

        // due to the way thread switching works on older ruby variants, we
        // cannot allocate anything passed to the blocking function on the stack
        ffiValues = ALLOC_N(void *, fnInfo->parameterCount);
        params = ALLOC_N(FFIStorage, fnInfo->parameterCount);
        bc = ALLOC_N(BlockingCall, 1);
        bc->info = fnInfo;
        bc->function = function;
        bc->ffiValues = ffiValues;
        bc->params = params;
        bc->retval = xmalloc(MAX(fnInfo->ffi_cif.rtype->size, FFI_SIZEOF_ARG));
        bc->stkretval = retval;

        rbffi_SetupCallParams(argc, argv,
            fnInfo->parameterCount, fnInfo->parameterTypes, params, ffiValues,
            fnInfo->callbackParameters, fnInfo->callbackCount, fnInfo->rbEnums);
        
        rb_ensure(do_blocking_call, (VALUE) bc, cleanup_blocking_call, (VALUE) bc);
        
    } else {

        ffiValues = ALLOCA_N(void *, fnInfo->parameterCount);
        params = ALLOCA_N(FFIStorage, fnInfo->parameterCount);

        rbffi_SetupCallParams(argc, argv,
            fnInfo->parameterCount, fnInfo->parameterTypes, params, ffiValues,
            fnInfo->callbackParameters, fnInfo->callbackCount, fnInfo->rbEnums);

#if !defined(HAVE_RUBY_THREAD_HAS_GVL_P)
        oldThread = rbffi_active_thread;
        rbffi_active_thread = rbffi_thread_self();
#endif
        retval = alloca(MAX(fnInfo->ffi_cif.rtype->size, FFI_SIZEOF_ARG));
        ffi_call(&fnInfo->ffi_cif, FFI_FN(function), retval, ffiValues);

#if !defined(HAVE_RUBY_THREAD_HAS_GVL_P)
        rbffi_active_thread = oldThread;
#endif
    }

    if (unlikely(!fnInfo->ignoreErrno)) {
        rbffi_save_errno();
    }

    return rbffi_NativeValue_ToRuby(fnInfo->returnType, fnInfo->rbReturnType, retval);
}

static inline void*
getPointer(VALUE value, int type)
{
    if (likely(type == T_DATA && rb_obj_is_kind_of(value, rbffi_AbstractMemoryClass))) {

        return ((AbstractMemory *) DATA_PTR(value))->address;

    } else if (type == T_DATA && rb_obj_is_kind_of(value, rbffi_StructClass)) {

        AbstractMemory* memory = ((Struct *) DATA_PTR(value))->pointer;
        return memory != NULL ? memory->address : NULL;

    } else if (type == T_STRING) {

        if (rb_safe_level() >= 1 && OBJ_TAINTED(value)) {
            rb_raise(rb_eSecurityError, "Unsafe string parameter");
        }
        return StringValuePtr(value);

    } else if (type == T_NIL) {

        return NULL;

    } else if (rb_respond_to(value, id_to_ptr)) {

        VALUE ptr = rb_funcall2(value, id_to_ptr, 0, NULL);
        if (rb_obj_is_kind_of(ptr, rbffi_AbstractMemoryClass) && TYPE(ptr) == T_DATA) {
            return ((AbstractMemory *) DATA_PTR(ptr))->address;
        }
        rb_raise(rb_eArgError, "to_ptr returned an invalid pointer");
    }

    rb_raise(rb_eArgError, ":pointer argument is not a valid pointer");
    return NULL;
}

static inline char*
getString(VALUE value, int type)
{
    if (type == T_STRING) {

        if (rb_safe_level() >= 1 && OBJ_TAINTED(value)) {
            rb_raise(rb_eSecurityError, "Unsafe string parameter");
        }

        return StringValueCStr(value);

    } else if (type == T_NIL) {
        return NULL;
    }

    rb_raise(rb_eArgError, "Invalid String value");
}


Invoker
rbffi_GetInvoker(FunctionType *fnInfo)
{
    return rbffi_CallFunction;
}


static void*
callback_param(VALUE proc, VALUE cbInfo)
{
    VALUE callback ;
    if (unlikely(proc == Qnil)) {
        return NULL ;
    }

    // Handle Function pointers here
    if (rb_obj_is_kind_of(proc, rbffi_FunctionClass)) {
        AbstractMemory* ptr;
        Data_Get_Struct(proc, AbstractMemory, ptr);
        return ptr->address;
    }

    //callback = rbffi_NativeCallback_ForProc(proc, cbInfo);
    callback = rbffi_Function_ForProc(cbInfo, proc);

    return ((AbstractMemory *) DATA_PTR(callback))->address;
}


void
rbffi_Call_Init(VALUE moduleFFI)
{
    id_to_ptr = rb_intern("to_ptr");
    id_to_native = rb_intern("to_native");
    id_map_symbol = rb_intern("__map_symbol");
}

