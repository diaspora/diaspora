/*
 * Copyright (c) 2009, Wayne Meissner
 * Copyright (c) 2009, Luc Heinrich <luc@honk-honk.com>
 * Copyright (c) 2009, Mike Dalessio <mike.dalessio@gmail.com>
 * Copyright (c) 2009, Aman Gupta.
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
static inline int getSignedInt(VALUE value, int type, int minValue, int maxValue, const char* typeName, VALUE enums);
static inline int getUnsignedInt(VALUE value, int type, int maxValue, const char* typeName);
static inline unsigned int getUnsignedInt32(VALUE value, int type);
static inline void* getPointer(VALUE value, int type);
static inline char* getString(VALUE value, int type);


#ifdef BYPASS_FFI
static long rbffi_GetLongValue(int idx, VALUE* argv, FunctionType* fnInfo);
static VALUE rbffi_InvokeVrL(int argc, VALUE* argv, void* function, FunctionType* fnInfo);
static VALUE rbffi_InvokeLrL(int argc, VALUE* argv, void* function, FunctionType* fnInfo);
static VALUE rbffi_InvokeLLrL(int argc, VALUE* argv, void* function, FunctionType* fnInfo);
static VALUE rbffi_InvokeLLLrL(int argc, VALUE* argv, void* function, FunctionType* fnInfo);
static VALUE rbffi_InvokeLLLLrL(int argc, VALUE* argv, void* function, FunctionType* fnInfo);
static VALUE rbffi_InvokeLLLLLrL(int argc, VALUE* argv, void* function, FunctionType* fnInfo);
static VALUE rbffi_InvokeLLLLLLrL(int argc, VALUE* argv, void* function, FunctionType* fnInfo);
static VALUE rbffi_InvokeLongParams(int argc, VALUE* argv, void* function, FunctionType* fnInfo);
#endif


static ID id_to_ptr, id_map_symbol;

void
rbffi_SetupCallParams(int argc, VALUE* argv, int paramCount, NativeType* paramTypes,
        FFIStorage* paramStorage, void** ffiValues,
        VALUE* callbackParameters, int callbackCount, VALUE enums)
{
    VALUE callbackProc = Qnil;
    FFIStorage* param = &paramStorage[0];
    int i, argidx, cbidx, argCount;

    if (paramCount != -1 && paramCount != argc) {
        if (argc == (paramCount - 1) && callbackCount == 1 && rb_block_given_p()) {
            callbackProc = rb_block_proc();
        } else {
            rb_raise(rb_eArgError, "wrong number of arguments (%d for %d)", argc, paramCount);
        }
    }

    argCount = paramCount != -1 ? paramCount : argc;

    for (i = 0, argidx = 0, cbidx = 0; i < argCount; ++i) {
        int type = argidx < argc ? TYPE(argv[argidx]) : T_NONE;
        ffiValues[i] = param;

        switch (paramTypes[i]) {

            case NATIVE_INT8:
                param->s8 = getSignedInt(argv[argidx++], type, -128, 127, "char", Qnil);
                ADJ(param, INT8);
                break;


            case NATIVE_INT16:
                param->s16 = getSignedInt(argv[argidx++], type, -0x8000, 0x7fff, "short", Qnil);
                ADJ(param, INT16);
                break;


            case NATIVE_INT32:
            case NATIVE_ENUM:
                param->s32 = getSignedInt(argv[argidx++], type, -0x80000000, 0x7fffffff, "int", enums);
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
                param->u8 = getUnsignedInt(argv[argidx++], type, 0xff, "unsigned char");
                ADJ(param, INT8);
                break;


            case NATIVE_UINT16:
                param->u16 = getUnsignedInt(argv[argidx++], type, 0xffff, "unsigned short");
                ADJ(param, INT16);
                break;


            case NATIVE_UINT32:
                /* Special handling/checking for unsigned 32 bit integers */
                param->u32 = getUnsignedInt32(argv[argidx++], type);
                ADJ(param, INT32);
                break;


            case NATIVE_INT64:
                if (type != T_FIXNUM && type != T_BIGNUM) {
                    rb_raise(rb_eTypeError, "Expected an Integer parameter");
                }
                param->i64 = NUM2LL(argv[argidx]);
                ADJ(param, INT64);
                ++argidx;
                break;


            case NATIVE_UINT64:
                if (type != T_FIXNUM && type != T_BIGNUM) {
                    rb_raise(rb_eTypeError, "Expected an Integer parameter");
                }
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
                if (type != T_FLOAT && type != T_FIXNUM) {
                    rb_raise(rb_eTypeError, "Expected a Float parameter");
                }
                param->f32 = (float) NUM2DBL(argv[argidx]);
                ADJ(param, FLOAT32);
                ++argidx;
                break;

            case NATIVE_FLOAT64:
                if (type != T_FLOAT && type != T_FIXNUM) {
                    rb_raise(rb_eTypeError, "Expected a Float parameter");
                }
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
                rb_raise(rb_eArgError, "Invalid parameter type: %d", paramTypes[i]);
        }
    }
}


#if defined(HAVE_NATIVETHREAD) && defined(HAVE_RB_THREAD_BLOCKING_REGION)

typedef struct BlockingCall_ {
    void* function;
    FunctionType* info;
    void **ffiValues;
    FFIStorage* retval;
} BlockingCall;

static VALUE
call_blocking_function(void* data)
{
    BlockingCall* b = (BlockingCall *) data;

    ffi_call(&b->info->ffi_cif, FFI_FN(b->function), b->retval, b->ffiValues);

    return Qnil;
}
#endif

VALUE
rbffi_CallFunction(int argc, VALUE* argv, void* function, FunctionType* fnInfo)
{
    void* retval;
    void** ffiValues;
    FFIStorage* params;

    ffiValues = ALLOCA_N(void *, fnInfo->parameterCount);
    params = ALLOCA_N(FFIStorage, fnInfo->parameterCount);
    retval = alloca(MAX(fnInfo->ffi_cif.rtype->size, FFI_SIZEOF_ARG));

    rbffi_SetupCallParams(argc, argv,
        fnInfo->parameterCount, fnInfo->nativeParameterTypes, params, ffiValues,
        fnInfo->callbackParameters, fnInfo->callbackCount, fnInfo->rbEnums);

#if defined(HAVE_NATIVETHREAD) && defined(HAVE_RB_THREAD_BLOCKING_REGION)
    if (unlikely(fnInfo->blocking)) {
        BlockingCall bc;

        bc.info = fnInfo;
        bc.function = function;
        bc.ffiValues = ffiValues;
        bc.retval = retval;

        rb_thread_blocking_region(call_blocking_function, &bc, (void *) -1, NULL);
    } else {
        ffi_call(&fnInfo->ffi_cif, FFI_FN(function), retval, ffiValues);
    }
#else
    ffi_call(&fnInfo->ffi_cif, FFI_FN(function), retval, ffiValues);
#endif

    if (!fnInfo->ignoreErrno) {
        rbffi_save_errno();
    }

    return rbffi_NativeValue_ToRuby(fnInfo->returnType, fnInfo->rbReturnType, retval,
        fnInfo->rbEnums);
}

static inline int
getSignedInt(VALUE value, int type, int minValue, int maxValue, const char* typeName, VALUE enums)
{
    int i;

    if (type == T_SYMBOL && enums != Qnil) {
        value = rb_funcall2(enums, id_map_symbol, 1, &value);
        if (value == Qnil) {
            rb_raise(rb_eTypeError, "Expected a valid enum constant");
        }

    } else if (type != T_FIXNUM && type != T_BIGNUM) {
        rb_raise(rb_eTypeError, "Expected an Integer parameter");
    }

    i = NUM2INT(value);
    if (i < minValue || i > maxValue) {
        rb_raise(rb_eRangeError, "Value %d outside %s range", i, typeName);
    }

    return i;
}

static inline int
getUnsignedInt(VALUE value, int type, int maxValue, const char* typeName)
{
    int i;

    if (type != T_FIXNUM && type != T_BIGNUM) {
        rb_raise(rb_eTypeError, "Expected an Integer parameter");
    }

    i = NUM2INT(value);
    if (i < 0 || i > maxValue) {
        rb_raise(rb_eRangeError, "Value %d outside %s range", i, typeName);
    }

    return i;
}

/* Special handling/checking for unsigned 32 bit integers */
static inline unsigned int
getUnsignedInt32(VALUE value, int type)
{
    long long i;

    if (type != T_FIXNUM && type != T_BIGNUM) {
        rb_raise(rb_eTypeError, "Expected an Integer parameter");
    }

    i = NUM2LL(value);
    if (i < 0L || i > 0xffffffffL) {
        rb_raise(rb_eRangeError, "Value %lld outside unsigned int range", i);
    }

    return (unsigned int) i;
}

static inline void*
getPointer(VALUE value, int type)
{
    if (type == T_DATA && rb_obj_is_kind_of(value, rbffi_AbstractMemoryClass)) {

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
#if defined(BYPASS_FFI) && (defined(__i386__) || defined(__x86_64__))
    int i;
    bool fastLong = fnInfo->abi == FFI_DEFAULT_ABI && !fnInfo->blocking && !fnInfo->hasStruct;

    switch (fnInfo->returnType->nativeType) {
        case NATIVE_VOID:
        case NATIVE_BOOL:
        case NATIVE_INT8:
        case NATIVE_UINT8:
        case NATIVE_INT16:
        case NATIVE_UINT16:
        case NATIVE_INT32:
        case NATIVE_UINT32:
        case NATIVE_LONG:
        case NATIVE_ULONG:
#ifdef __x86_64__
        case NATIVE_INT64:
        case NATIVE_UINT64:
#endif
        case NATIVE_STRING:
        case NATIVE_POINTER:
            break;
        default:
            fastLong = false;
            break;
    }

    for (i = 0; fastLong && i < fnInfo->parameterCount; ++i) {
        switch (fnInfo->nativeParameterTypes[i]) {
            case NATIVE_BOOL:
            case NATIVE_INT8:
            case NATIVE_UINT8:
            case NATIVE_INT16:
            case NATIVE_UINT16:
            case NATIVE_INT32:
            case NATIVE_UINT32:
            case NATIVE_LONG:
            case NATIVE_ULONG:
#ifdef __x86_64__
            case NATIVE_INT64:
            case NATIVE_UINT64:
#endif
            case NATIVE_STRING:
            case NATIVE_POINTER:
            case NATIVE_BUFFER_IN:
            case NATIVE_BUFFER_OUT:
            case NATIVE_BUFFER_INOUT:
            case NATIVE_FUNCTION:
            case NATIVE_CALLBACK:
                break;
            default:
                fastLong = false;
                break;
        }
    }

    if (fastLong && fnInfo->callbackCount < 1) {
        switch (fnInfo->parameterCount) {
            case 0:
                return rbffi_InvokeVrL;
            case 1:
                return rbffi_InvokeLrL;
            case 2:
                return rbffi_InvokeLLrL;
            case 3:
                return rbffi_InvokeLLLrL;
            case 4:
                return rbffi_InvokeLLLLrL;
            case 5:
                return rbffi_InvokeLLLLLrL;
            case 6:
                return rbffi_InvokeLLLLLLrL;

            default:
                break;
        }

    } else if (fastLong && fnInfo->parameterCount <= 6) {
        return rbffi_InvokeLongParams;
    }
#endif

    return rbffi_CallFunction;
}

#if defined(BYPASS_FFI) && (defined(__i386__) || defined(__x86_64__))
typedef long L;

static long
rbffi_GetLongValue(int idx, VALUE* argv, FunctionType* fnInfo)
{
    VALUE value = argv[idx];
    NativeType nativeType = fnInfo->nativeParameterTypes[idx];
    int type = TYPE(value);

    switch (nativeType) {
        case NATIVE_INT8:
            return getSignedInt(value, type, -128, 127, "char", fnInfo->rbEnums);

        case NATIVE_INT16:
            return getSignedInt(value, type, -0x8000, 0x7fff, "short", fnInfo->rbEnums);

        case NATIVE_INT32:
        case NATIVE_ENUM:
            return getSignedInt(value, type, -0x80000000, 0x7fffffff, "int", fnInfo->rbEnums);

        case NATIVE_BOOL:
            if (type != T_TRUE && type != T_FALSE) {
                rb_raise(rb_eTypeError, "Expected a Boolean parameter");
            }
            return RTEST(value) ? 1 : 0;

        case NATIVE_UINT8:
            return getUnsignedInt(value, type, 0xff, "unsigned char");

        case NATIVE_UINT16:
            return getUnsignedInt(value, type, 0xffff, "unsigned short");

        case NATIVE_UINT32:
            /* Special handling/checking for unsigned 32 bit integers */
            return getUnsignedInt32(value, type);

        case NATIVE_LONG:
            return NUM2LONG(value);

        case NATIVE_ULONG:
            return NUM2ULONG(value);

#ifdef __x86_64__
        case NATIVE_INT64:
            if (type != T_FIXNUM && type != T_BIGNUM) {
                rb_raise(rb_eTypeError, "Expected an Integer parameter");
            }
            return NUM2LL(value);

        case NATIVE_UINT64:
            if (type != T_FIXNUM && type != T_BIGNUM) {
                rb_raise(rb_eTypeError, "Expected an Integer parameter");
            }
            return NUM2ULL(value);
#endif
        case NATIVE_STRING:
            return (intptr_t) getString(value, type);

        case NATIVE_POINTER:
        case NATIVE_BUFFER_IN:
        case NATIVE_BUFFER_OUT:
        case NATIVE_BUFFER_INOUT:
            return (intptr_t) getPointer(value, type);

        default:
            rb_raise(rb_eTypeError, "unsupported integer type %d", nativeType);
            return 0;
    }
}

static inline void
checkArity(int argc, int arity) {
    if (unlikely(argc != arity)) {
        rb_raise(rb_eArgError, "wrong number of arguments (%d for %d)", argc, arity);
    }
}

static inline bool
isLongValue(VALUE value)
{
    int type = TYPE(value);

    return type == T_FIXNUM || type == T_BIGNUM
            || type == T_STRING || type == T_NIL
            || (type == T_DATA && rb_obj_is_kind_of(value, rbffi_AbstractMemoryClass))
            || (type == T_DATA && rb_obj_is_kind_of(value, rbffi_StructClass))
            || rb_respond_to(value, id_to_ptr);
}

static VALUE
returnL(FunctionType* fnInfo, L* result)
{
    if (unlikely(!fnInfo->ignoreErrno)) {
        rbffi_save_errno();
    }

    /*
     * This needs to do custom boxing of the return value, since a function
     * may only fill out the lower 8, 16 or 32 bits of %al, %ah, %eax, %rax, and
     * the upper part will be garbage.  This will truncate the value again, then
     * sign extend it.
     */
    switch (fnInfo->returnType->nativeType) {
        case NATIVE_VOID:
            return Qnil;

        case NATIVE_INT8:
          return INT2NUM(*(signed char *) result);

        case NATIVE_INT16:
          return INT2NUM(*(signed short *) result);

        case NATIVE_INT32:
          return INT2NUM(*(signed int *) result);

        case NATIVE_LONG:
          return LONG2NUM(*(signed long *) result);

        case NATIVE_UINT8:
          return UINT2NUM(*(unsigned char *) result);

        case NATIVE_UINT16:
          return UINT2NUM(*(unsigned short *) result);

        case NATIVE_UINT32:
          return UINT2NUM(*(unsigned int *) result);

        case NATIVE_ULONG:
          return ULONG2NUM(*(unsigned long *) result);

#ifdef __x86_64__
        case NATIVE_INT64:
            return LL2NUM(*(signed long long *) result);

        case NATIVE_UINT64:
            return ULL2NUM(*(unsigned long long *) result);
#endif /* __x86_64__ */

        case NATIVE_STRING:
            return *(void **) result != 0 ? rb_tainted_str_new2(*(char **) result) : Qnil;

        case NATIVE_POINTER:
            return rbffi_Pointer_NewInstance(*(void **) result);

        case NATIVE_BOOL:
            return *(char *) result != 0 ? Qtrue : Qfalse;

        default:
            rb_raise(rb_eRuntimeError, "invalid return type: %d", fnInfo->returnType->nativeType);
            return Qnil;
    }
}

static VALUE
rbffi_InvokeVrL(int argc, VALUE* argv, void* function, FunctionType* fnInfo)
{
    L (*fn)(void) = (L (*)(void)) function;
    L result;

    checkArity(argc, 0);

    result = (*fn)();

    return returnL(fnInfo, &result);
}

static bool
checkArgs(int argc, VALUE* argv, FunctionType* fnInfo)
{
    int i;

    checkArity(argc, fnInfo->parameterCount);
    for (i = 0; i < fnInfo->parameterCount; ++i) {
        if (unlikely(!isLongValue(argv[i]))) {
            return false;
        }
    }

    return true;
}

#define LARG(fnInfo, argv, i) \
    rbffi_GetLongValue(i, argv, fnInfo)

#define LCALL(fnInfo, argc, argv, fn, a...) ({ \
    L result; \
    \
    if (unlikely(!checkArgs(argc, argv, fnInfo))) { \
        return rbffi_CallFunction(argc, argv, function, fnInfo); \
    } \
    \
    result = (*(fn))(a); \
    \
    returnL(fnInfo, &result); \
})

static VALUE
rbffi_InvokeLrL(int argc, VALUE* argv, void* function, FunctionType* fnInfo)
{
    L (*fn)(L) = (L (*)(L)) function;
    L result;

    checkArity(argc, 1);

    if (unlikely(!isLongValue(argv[0]))) {
        return rbffi_CallFunction(argc, argv, function, fnInfo);
    }

    result = (*fn)(LARG(fnInfo, argv, 0));

    return returnL(fnInfo, &result);
}

static VALUE
rbffi_InvokeLLrL(int argc, VALUE* argv, void* function, FunctionType* fnInfo)
{
    L (*fn)(L, L) = (L (*)(L, L)) function;
    L result;

    checkArity(argc, 2);

    if (unlikely(!isLongValue(argv[0])) || unlikely(!isLongValue(argv[1]))) {
        return rbffi_CallFunction(argc, argv, function, fnInfo);
    }

    result = (*fn)(LARG(fnInfo, argv, 0), LARG(fnInfo, argv, 1));

    return returnL(fnInfo, &result);
}

static VALUE
rbffi_InvokeLLLrL(int argc, VALUE* argv, void* function, FunctionType* fnInfo)
{
    L (*fn)(L, L, L) = (L (*)(L, L, L)) function;
    L result;

    checkArity(argc, 3);

    if (unlikely(!isLongValue(argv[0])) || unlikely(!isLongValue(argv[1])) || unlikely(!isLongValue(argv[2]))) {
        return rbffi_CallFunction(argc, argv, function, fnInfo);
    }
    
    result = (*fn)(LARG(fnInfo, argv, 0), LARG(fnInfo, argv, 1), LARG(fnInfo, argv, 2));

    return returnL(fnInfo, &result);
}


static VALUE
rbffi_InvokeLLLLrL(int argc, VALUE* argv, void* function, FunctionType* fnInfo)
{
    return LCALL(fnInfo, argc, argv, (L (*)(L, L, L, L)) function,
        LARG(fnInfo, argv, 0), LARG(fnInfo, argv, 1),
        LARG(fnInfo, argv, 2), LARG(fnInfo, argv, 3));
}

static VALUE
rbffi_InvokeLLLLLrL(int argc, VALUE* argv, void* function, FunctionType* fnInfo)
{
    return LCALL(fnInfo, argc, argv, (L (*)(L, L, L, L, L)) function,
        LARG(fnInfo, argv, 0), LARG(fnInfo, argv, 1), LARG(fnInfo, argv, 2),
        LARG(fnInfo, argv, 3), LARG(fnInfo, argv, 4));
}

static VALUE
rbffi_InvokeLLLLLLrL(int argc, VALUE* argv, void* function, FunctionType* fnInfo)
{
    return LCALL(fnInfo, argc, argv, (L (*)(L, L, L, L, L, L)) function,
        LARG(fnInfo, argv, 0), LARG(fnInfo, argv, 1), LARG(fnInfo, argv, 2),
        LARG(fnInfo, argv, 3), LARG(fnInfo, argv, 4), LARG(fnInfo, argv, 5));
}

static VALUE
rbffi_InvokeLongParams(int argc, VALUE* argv, void* function, FunctionType* fnInfo)
{
    void **ffiValues = NULL;
    FFIStorage* params = NULL;
    L result;

    if (fnInfo->parameterCount > 0) {
        ffiValues = ALLOCA_N(void *, fnInfo->parameterCount);
        params = ALLOCA_N(FFIStorage, fnInfo->parameterCount);

        rbffi_SetupCallParams(argc, argv,
            fnInfo->parameterCount, fnInfo->nativeParameterTypes, params, ffiValues,
            fnInfo->callbackParameters, fnInfo->callbackCount, fnInfo->rbEnums);

        switch (fnInfo->parameterCount) {
            case 0:
                result = ((L(*)(void)) function)();
                break;

            case 1:
                result = ((L(*)(L)) function)(*(L *) ffiValues[0]);
                break;

            case 2:
                result = ((L(*)(L, L)) function)(*(L *) ffiValues[0],
                        *(L *) ffiValues[1]);
                break;

            case 3:
                result = ((L(*)(L, L, L)) function)(*(L *) ffiValues[0],
                        *(L *) ffiValues[1], *(L *) ffiValues[2]);
                break;

            case 4:
                result = ((L(*)(L, L, L, L)) function)(*(L *) ffiValues[0],
                        *(L *) ffiValues[1], *(L *) ffiValues[2], *(L *) ffiValues[3]);
                break;

            case 5:
                result = ((L(*)(L, L, L, L, L)) function)(*(L *) ffiValues[0],
                        *(L *) ffiValues[1], *(L *) ffiValues[2], *(L *) ffiValues[3],
                        *(L *) ffiValues[4]);
                break;

            case 6:
                result = ((L(*)(L, L, L, L, L, L)) function)(*(L *) ffiValues[0],
                        *(L *) ffiValues[1], *(L *) ffiValues[2], *(L *) ffiValues[3],
                        *(L *) ffiValues[4], *(L *) ffiValues[5]);
                break;

            default:
                rb_raise(rb_eRuntimeError, "BUG: should not reach this point");
                return Qnil;
        }
    }

    return returnL(fnInfo, &result);
}

#endif /* BYPASS_FFI */

static void*
callback_param(VALUE proc, VALUE cbInfo)
{
    VALUE callback ;
    if (proc == Qnil) {
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
    id_map_symbol = rb_intern("__map_symbol");
}

