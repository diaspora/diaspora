/*
 * Copyright (c) 2009, Wayne Meissner
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

#include "MethodHandle.h"


#include <sys/param.h>
#include <sys/types.h>
#ifndef _WIN32
# include <sys/mman.h>
#endif
#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include <ruby.h>

#include <ffi.h>
#include "rbffi.h"
#include "compat.h"

#include "AbstractMemory.h"
#include "Pointer.h"
#include "Struct.h"
#include "Platform.h"
#include "Type.h"
#include "LastError.h"
#include "Call.h"
#include "ClosurePool.h"
#include "Function.h"

typedef struct Function_ {
    AbstractMemory memory;
    FunctionType* info;
    MethodHandle* methodHandle;
    bool autorelease;
    Closure* closure;
    VALUE rbProc;
    VALUE rbFunctionInfo;
} Function;

static void function_mark(Function *);
static void function_free(Function *);
static VALUE function_init(VALUE self, VALUE rbFunctionInfo, VALUE rbProc);
static void callback_invoke(ffi_cif* cif, void* retval, void** parameters, void* user_data);
static bool callback_prep(void* ctx, void* code, Closure* closure, char* errmsg, size_t errmsgsize);

VALUE rbffi_FunctionClass = Qnil;

static ID id_call = 0, id_cbtable = 0, id_cb_ref = 0;

static VALUE
function_allocate(VALUE klass)
{
    Function *fn;
    VALUE obj;

    obj = Data_Make_Struct(klass, Function, function_mark, function_free, fn);

    fn->memory.access = MEM_RD;

    fn->rbProc = Qnil;
    fn->rbFunctionInfo = Qnil;
    fn->autorelease = true;

    return obj;
}

static void
function_mark(Function *fn)
{
    rb_gc_mark(fn->rbProc);
    rb_gc_mark(fn->rbFunctionInfo);
}

static void
function_free(Function *fn)
{
    if (fn->methodHandle != NULL) {
        rbffi_MethodHandle_Free(fn->methodHandle);
    }

    if (fn->closure != NULL && fn->autorelease) {
        rbffi_Closure_Free(fn->closure);
    }

    xfree(fn);
}

static VALUE
function_initialize(int argc, VALUE* argv, VALUE self)
{
    
    VALUE rbReturnType = Qnil, rbParamTypes = Qnil, rbProc = Qnil, rbOptions = Qnil;
    VALUE rbFunctionInfo = Qnil;
    VALUE infoArgv[3];
    int nargs;

    nargs = rb_scan_args(argc, argv, "22", &rbReturnType, &rbParamTypes, &rbProc, &rbOptions);

    //
    // Callback with block,
    // e.g. Function.new(:int, [ :int ]) { |i| blah }
    // or   Function.new(:int, [ :int ], { :convention => :stdcall }) { |i| blah }
    //
    if (rb_block_given_p()) {
        if (nargs > 3) {
            rb_raise(rb_eArgError, "cannot create function with both proc/address and block");
        }
        rbOptions = rbProc;
        rbProc = rb_block_proc();
    } else {
        // Callback with proc, or Function with address
        // e.g. Function.new(:int, [ :int ], Proc.new { |i| })
        //      Function.new(:int, [ :int ], Proc.new { |i| }, { :convention => :stdcall })
        //      Function.new(:int, [ :int ], addr)
        //      Function.new(:int, [ :int ], addr, { :convention => :stdcall })
    }
    
    infoArgv[0] = rbReturnType;
    infoArgv[1] = rbParamTypes;
    infoArgv[2] = rbOptions;
    rbFunctionInfo = rb_class_new_instance(rbOptions != Qnil ? 3 : 2, infoArgv, rbffi_FunctionTypeClass);

    function_init(self, rbFunctionInfo, rbProc);
    
    return self;
}

VALUE
rbffi_Function_NewInstance(VALUE rbFunctionInfo, VALUE rbProc)
{
    return function_init(function_allocate(rbffi_FunctionClass), rbFunctionInfo, rbProc);
}

VALUE
rbffi_Function_ForProc(VALUE rbFunctionInfo, VALUE proc)
{
    VALUE callback, cbref, cbTable;
    Function* fp;

    cbref = RTEST(rb_ivar_defined(proc, id_cb_ref)) ? rb_ivar_get(proc, id_cb_ref) : Qnil;
    /* If the first callback reference has the same function function signature, use it */
    if (cbref != Qnil && CLASS_OF(cbref) == rbffi_FunctionClass) {
        Data_Get_Struct(cbref, Function, fp);
        if (fp->rbFunctionInfo == rbFunctionInfo) {
            return cbref;
        }
    }
    
    cbTable = RTEST(rb_ivar_defined(proc, id_cbtable)) ? rb_ivar_get(proc, id_cbtable) : Qnil;
    if (cbTable != Qnil && (callback = rb_hash_aref(cbTable, rbFunctionInfo)) != Qnil) {
        return callback;
    }
    
    /* No existing function for the proc with that signature, create a new one and cache it */
    callback = rbffi_Function_NewInstance(rbFunctionInfo, proc);
    if (cbref == Qnil) {
        /* If there is no other cb already cached for this proc, we can use the ivar slot */
        rb_ivar_set(proc, id_cb_ref, callback);
    } else {
        /* The proc instance has been used as more than one type of callback, store extras in a hash */
        cbTable = rb_hash_new();
        rb_ivar_set(proc, id_cbtable, cbTable);
        rb_hash_aset(cbTable, rbFunctionInfo, callback);
    }

    return callback;
}

static VALUE
function_init(VALUE self, VALUE rbFunctionInfo, VALUE rbProc)
{
    Function* fn = NULL;
    
    Data_Get_Struct(self, Function, fn);

    fn->rbFunctionInfo = rbFunctionInfo;

    Data_Get_Struct(fn->rbFunctionInfo, FunctionType, fn->info);

    if (rb_obj_is_kind_of(rbProc, rbffi_PointerClass)) {
        AbstractMemory* memory;
        Data_Get_Struct(rbProc, AbstractMemory, memory);
        fn->memory = *memory;

    } else if (rb_obj_is_kind_of(rbProc, rb_cProc) || rb_respond_to(rbProc, id_call)) {
        if (fn->info->closurePool == NULL) {
            fn->info->closurePool = rbffi_ClosurePool_New(sizeof(ffi_closure), callback_prep, fn->info);
            if (fn->info->closurePool == NULL) {
                rb_raise(rb_eNoMemError, "failed to create closure pool");
            }
        }

        fn->closure = rbffi_Closure_Alloc(fn->info->closurePool);
        fn->closure->info = fn;
        fn->memory.address = fn->closure->code;
        fn->memory.size = sizeof(*fn->closure);
        fn->autorelease = true;

    } else {
        rb_raise(rb_eTypeError, "wrong argument type.  Expected pointer or proc");
    }
    
    fn->rbProc = rbProc;

    return self;
}

static VALUE
function_call(int argc, VALUE* argv, VALUE self)
{
    Function* fn;

    Data_Get_Struct(self, Function, fn);

    return (*fn->info->invoke)(argc, argv, fn->memory.address, fn->info);
}

static VALUE
function_attach(VALUE self, VALUE module, VALUE name)
{
    Function* fn;
    char var[1024];

    Data_Get_Struct(self, Function, fn);

    if (fn->info->parameterCount == -1) {
        rb_raise(rb_eRuntimeError, "cannot attach variadic functions");
        return Qnil;
    }

    if (!rb_obj_is_kind_of(module, rb_cModule)) {
        rb_raise(rb_eRuntimeError, "trying to attach function to non-module");
        return Qnil;
    }

    if (fn->methodHandle == NULL) {
        fn->methodHandle = rbffi_MethodHandle_Alloc(fn->info, fn->memory.address);
    }

    //
    // Stash the Function in a module variable so it does not get garbage collected
    //
    snprintf(var, sizeof(var), "@@%s", StringValueCStr(name));
    rb_cv_set(module, var, self);

    rb_define_singleton_method(module, StringValueCStr(name),
            rbffi_MethodHandle_CodeAddress(fn->methodHandle), -1);

    
    rb_define_method(module, StringValueCStr(name),
            rbffi_MethodHandle_CodeAddress(fn->methodHandle), -1);

    return self;
}

static VALUE
function_set_autorelease(VALUE self, VALUE autorelease)
{
    Function* fn;

    Data_Get_Struct(self, Function, fn);

    fn->autorelease = RTEST(autorelease);

    return self;
}

static VALUE
function_autorelease_p(VALUE self)
{
    Function* fn;

    Data_Get_Struct(self, Function, fn);

    return fn->autorelease ? Qtrue : Qfalse;
}

static VALUE
function_release(VALUE self)
{
    Function* fn;

    Data_Get_Struct(self, Function, fn);

    if (fn->closure == NULL) {
        rb_raise(rb_eRuntimeError, "cannot free function which was not allocated");
    }
    
    rbffi_Closure_Free(fn->closure);
    fn->closure = NULL;
    
    return self;
}

static void
callback_invoke(ffi_cif* cif, void* retval, void** parameters, void* user_data)
{
    Closure* closure = (Closure *) user_data;
    Function* fn = (Function *) closure->info;
    FunctionType *cbInfo = fn->info;
    VALUE* rbParams;
    VALUE rbReturnValue;
    int i;

    rbParams = ALLOCA_N(VALUE, cbInfo->parameterCount);
    for (i = 0; i < cbInfo->parameterCount; ++i) {
        VALUE param;
        switch (cbInfo->parameterTypes[i]->nativeType) {
            case NATIVE_INT8:
                param = INT2NUM(*(int8_t *) parameters[i]);
                break;
            case NATIVE_UINT8:
                param = UINT2NUM(*(uint8_t *) parameters[i]);
                break;
            case NATIVE_INT16:
                param = INT2NUM(*(int16_t *) parameters[i]);
                break;
            case NATIVE_UINT16:
                param = UINT2NUM(*(uint16_t *) parameters[i]);
                break;
            case NATIVE_INT32:
                param = INT2NUM(*(int32_t *) parameters[i]);
                break;
            case NATIVE_UINT32:
                param = UINT2NUM(*(uint32_t *) parameters[i]);
                break;
            case NATIVE_INT64:
                param = LL2NUM(*(int64_t *) parameters[i]);
                break;
            case NATIVE_UINT64:
                param = ULL2NUM(*(uint64_t *) parameters[i]);
                break;
            case NATIVE_LONG:
                param = LONG2NUM(*(long *) parameters[i]);
                break;
            case NATIVE_ULONG:
                param = ULONG2NUM(*(unsigned long *) parameters[i]);
                break;
            case NATIVE_FLOAT32:
                param = rb_float_new(*(float *) parameters[i]);
                break;
            case NATIVE_FLOAT64:
                param = rb_float_new(*(double *) parameters[i]);
                break;
            case NATIVE_STRING:
                param = (*(void **) parameters[i] != NULL) ? rb_tainted_str_new2(*(char **) parameters[i]) : Qnil;
                break;
            case NATIVE_POINTER:
                param = rbffi_Pointer_NewInstance(*(void **) parameters[i]);
                break;
            case NATIVE_BOOL:
                param = (*(uint8_t *) parameters[i]) ? Qtrue : Qfalse;
                break;

            case NATIVE_FUNCTION:
            case NATIVE_CALLBACK:
                param = rbffi_NativeValue_ToRuby(cbInfo->parameterTypes[i],
                     rb_ary_entry(cbInfo->rbParameterTypes, i), parameters[i], Qnil);
                break;
            default:
                param = Qnil;
                break;
        }
        rbParams[i] = param;
    }
    rbReturnValue = rb_funcall2(fn->rbProc, id_call, cbInfo->parameterCount, rbParams);
    if (rbReturnValue == Qnil || TYPE(rbReturnValue) == T_NIL) {
        memset(retval, 0, cbInfo->ffiReturnType->size);
    } else switch (cbInfo->returnType->nativeType) {
        case NATIVE_INT8:
        case NATIVE_INT16:
        case NATIVE_INT32:
            *((ffi_sarg *) retval) = NUM2INT(rbReturnValue);
            break;
        case NATIVE_UINT8:
        case NATIVE_UINT16:
        case NATIVE_UINT32:
            *((ffi_arg *) retval) = NUM2UINT(rbReturnValue);
            break;
        case NATIVE_INT64:
            *((int64_t *) retval) = NUM2LL(rbReturnValue);
            break;
        case NATIVE_UINT64:
            *((uint64_t *) retval) = NUM2ULL(rbReturnValue);
            break;
        case NATIVE_LONG:
            *((ffi_sarg *) retval) = NUM2LONG(rbReturnValue);
            break;
        case NATIVE_ULONG:
            *((ffi_arg *) retval) = NUM2ULONG(rbReturnValue);
            break;
        case NATIVE_FLOAT32:
            *((float *) retval) = (float) NUM2DBL(rbReturnValue);
            break;
        case NATIVE_FLOAT64:
            *((double *) retval) = NUM2DBL(rbReturnValue);
            break;
        case NATIVE_POINTER:
            if (TYPE(rbReturnValue) == T_DATA && rb_obj_is_kind_of(rbReturnValue, rbffi_PointerClass)) {
                *((void **) retval) = ((AbstractMemory *) DATA_PTR(rbReturnValue))->address;
            } else {
                // Default to returning NULL if not a value pointer object.  handles nil case as well
                *((void **) retval) = NULL;
            }
            break;

        case NATIVE_BOOL:
            *((ffi_arg *) retval) = rbReturnValue == Qtrue;
            break;

        case NATIVE_FUNCTION:
        case NATIVE_CALLBACK:
            if (TYPE(rbReturnValue) == T_DATA && rb_obj_is_kind_of(rbReturnValue, rbffi_PointerClass)) {

                *((void **) retval) = ((AbstractMemory *) DATA_PTR(rbReturnValue))->address;

            } else if (rb_obj_is_kind_of(rbReturnValue, rb_cProc) || rb_respond_to(rbReturnValue, id_call)) {
                VALUE function;

                function = rbffi_Function_ForProc(cbInfo->rbReturnType, rbReturnValue);

                *((void **) retval) = ((AbstractMemory *) DATA_PTR(function))->address;
            } else {
                *((void **) retval) = NULL;
            }
            break;

        default:
            *((ffi_arg *) retval) = 0;
            break;
    }
}


static bool
callback_prep(void* ctx, void* code, Closure* closure, char* errmsg, size_t errmsgsize)
{
    FunctionType* fnInfo = (FunctionType *) ctx;
    ffi_status ffiStatus;

    ffiStatus = ffi_prep_closure(code, &fnInfo->ffi_cif, callback_invoke, closure);
    if (ffiStatus != FFI_OK) {
        snprintf(errmsg, errmsgsize, "ffi_prep_closure failed.  status=%#x", ffiStatus);
        return false;
    }

    return true;
}

void
rbffi_Function_Init(VALUE moduleFFI)
{
    rbffi_FunctionInfo_Init(moduleFFI);
    rbffi_FunctionClass = rb_define_class_under(moduleFFI, "Function", rbffi_PointerClass);
    
    rb_global_variable(&rbffi_FunctionClass);
    rb_define_alloc_func(rbffi_FunctionClass, function_allocate);

    rb_define_method(rbffi_FunctionClass, "initialize", function_initialize, -1);
    rb_define_method(rbffi_FunctionClass, "call", function_call, -1);
    rb_define_method(rbffi_FunctionClass, "attach", function_attach, 2);
    rb_define_method(rbffi_FunctionClass, "free", function_release, 0);
    rb_define_method(rbffi_FunctionClass, "autorelease=", function_set_autorelease, 1);
    rb_define_method(rbffi_FunctionClass, "autorelease", function_autorelease_p, 0);
    rb_define_method(rbffi_FunctionClass, "autorelease?", function_autorelease_p, 0);

    id_call = rb_intern("call");
    id_cbtable = rb_intern("@__ffi_callback_table__");
    id_cb_ref = rb_intern("@__ffi_callback__");
}

