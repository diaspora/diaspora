/*
 * Copyright (c) 2009-2011 Wayne Meissner
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
#if defined(HAVE_NATIVETHREAD) && !defined(_WIN32)
#include <pthread.h>
#endif
#include <fcntl.h>

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
#include "MappedType.h"
#include "Thread.h"

typedef struct Function_ {
    Pointer base;
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
static void* callback_with_gvl(void* data);

#if !defined(_WIN32) || defined(HAVE_RB_THREAD_BLOCKING_REGION)
# define DEFER_ASYNC_CALLBACK 1
#endif


#if defined(DEFER_ASYNC_CALLBACK)
static VALUE async_cb_event(void *);
static VALUE async_cb_call(void *);
#endif

#ifdef HAVE_RB_THREAD_CALL_WITH_GVL
extern void *rb_thread_call_with_gvl(void *(*func)(void *), void *data1);
#endif

VALUE rbffi_FunctionClass = Qnil;

#if defined(DEFER_ASYNC_CALLBACK)
static VALUE async_cb_thread = Qnil;
#endif

static ID id_call = 0, id_to_native = 0, id_from_native = 0, id_cbtable = 0, id_cb_ref = 0;

struct gvl_callback {
    Closure* closure;
    void*    retval;
    void**   parameters;
    bool done;
#if defined(DEFER_ASYNC_CALLBACK)
    struct gvl_callback* next;
# ifndef _WIN32
    pthread_cond_t async_cond;
    pthread_mutex_t async_mutex;
# else
    HANDLE async_event;
# endif
#endif
};


#if defined(DEFER_ASYNC_CALLBACK)
static struct gvl_callback* async_cb_list = NULL;
# ifndef _WIN32
    static pthread_mutex_t async_cb_mutex = PTHREAD_MUTEX_INITIALIZER;
    static pthread_cond_t async_cb_cond = PTHREAD_COND_INITIALIZER;
#  if !defined(HAVE_RB_THREAD_BLOCKING_REGION)
    static int async_cb_pipe[2];
#  endif
# else
static HANDLE async_cb_cond;
static CRITICAL_SECTION async_cb_lock;
# endif
#endif


static VALUE
function_allocate(VALUE klass)
{
    Function *fn;
    VALUE obj;

    obj = Data_Make_Struct(klass, Function, function_mark, function_free, fn);

    fn->base.memory.flags = MEM_RD;
    fn->base.rbParent = Qnil;
    fn->rbProc = Qnil;
    fn->rbFunctionInfo = Qnil;
    fn->autorelease = true;

    return obj;
}

static void
function_mark(Function *fn)
{
    rb_gc_mark(fn->base.rbParent);
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

static VALUE
function_initialize_copy(VALUE self, VALUE other)
{
    rb_raise(rb_eRuntimeError, "cannot duplicate function instances");
    return Qnil;
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
        Pointer* orig;
        Data_Get_Struct(rbProc, Pointer, orig);
        fn->base.memory = orig->memory;
        fn->base.rbParent = rbProc;

    } else if (rb_obj_is_kind_of(rbProc, rb_cProc) || rb_respond_to(rbProc, id_call)) {
        if (fn->info->closurePool == NULL) {
            fn->info->closurePool = rbffi_ClosurePool_New(sizeof(ffi_closure), callback_prep, fn->info);
            if (fn->info->closurePool == NULL) {
                rb_raise(rb_eNoMemError, "failed to create closure pool");
            }
        }

#if defined(DEFER_ASYNC_CALLBACK)
        if (async_cb_thread == Qnil) {
#if !defined(HAVE_RB_THREAD_BLOCKING_REGION)
            pipe(async_cb_pipe);
            fcntl(async_cb_pipe[0], F_SETFL, fcntl(async_cb_pipe[0], F_GETFL) | O_NONBLOCK);
            fcntl(async_cb_pipe[1], F_SETFL, fcntl(async_cb_pipe[1], F_GETFL) | O_NONBLOCK);
#endif
            async_cb_thread = rb_thread_create(async_cb_event, NULL);
        }

#endif

        fn->closure = rbffi_Closure_Alloc(fn->info->closurePool);
        fn->closure->info = fn;
        fn->base.memory.address = fn->closure->code;
        fn->base.memory.size = sizeof(*fn->closure);
        fn->autorelease = true;

    } else {
        rb_raise(rb_eTypeError, "wrong argument type %s, expected pointer or proc",
                rb_obj_classname(rbProc));
    }
    
    fn->rbProc = rbProc;

    return self;
}

static VALUE
function_call(int argc, VALUE* argv, VALUE self)
{
    Function* fn;

    Data_Get_Struct(self, Function, fn);

    return (*fn->info->invoke)(argc, argv, fn->base.memory.address, fn->info);
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
        fn->methodHandle = rbffi_MethodHandle_Alloc(fn->info, fn->base.memory.address);
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
    struct gvl_callback cb;
    cb.closure = (Closure *) user_data;
    cb.retval = retval;
    cb.parameters = parameters;
    cb.done = false;

    if (rbffi_thread_has_gvl_p()) {
        callback_with_gvl(&cb);
    
#if defined(HAVE_RUBY_NATIVE_THREAD_P) && defined (HAVE_RB_THREAD_CALL_WITH_GVL)
    } else if (ruby_native_thread_p()) {
        rb_thread_call_with_gvl(callback_with_gvl, &cb);
#endif
#if defined(DEFER_ASYNC_CALLBACK) && !defined(_WIN32)
    } else {
        bool empty = false;

        pthread_mutex_init(&cb.async_mutex, NULL);
        pthread_cond_init(&cb.async_cond, NULL);

        // Now signal the async callback thread
        pthread_mutex_lock(&async_cb_mutex);
        empty = async_cb_list == NULL;
        cb.next = async_cb_list;
        async_cb_list = &cb;
        pthread_mutex_unlock(&async_cb_mutex);

#if !defined(HAVE_RB_THREAD_BLOCKING_REGION)
        // Only signal if the list was empty
        if (empty) {
            char c;
            write(async_cb_pipe[1], &c, 1);
        }
#else
        pthread_cond_signal(&async_cb_cond);
#endif

        // Wait for the thread executing the ruby callback to signal it is done
        pthread_mutex_lock(&cb.async_mutex);
        while (!cb.done) {
            pthread_cond_wait(&cb.async_cond, &cb.async_mutex);
        }
        pthread_mutex_unlock(&cb.async_mutex);
        pthread_cond_destroy(&cb.async_cond);
        pthread_mutex_destroy(&cb.async_mutex);

#elif defined(DEFER_ASYNC_CALLBACK) && defined(_WIN32)
    } else {
        cb.async_event = CreateEvent(NULL, FALSE, FALSE, NULL);
        
        // Now signal the async callback thread
        EnterCriticalSection(&async_cb_lock);
        cb.next = async_cb_list;
        async_cb_list = &cb;
        LeaveCriticalSection(&async_cb_lock);

        SetEvent(async_cb_cond);
        
        // Wait for the thread executing the ruby callback to signal it is done
        WaitForSingleObject(cb.async_event, INFINITE);
        CloseHandle(cb.async_event);
#endif
    }
}

#if defined(DEFER_ASYNC_CALLBACK)
struct async_wait {
    void* cb;
    bool stop;
};

static VALUE async_cb_wait(void *);
static void async_cb_stop(void *);

#if defined(HAVE_RB_THREAD_BLOCKING_REGION)
static VALUE
async_cb_event(void* unused)
{
    struct async_wait w = { 0 };

    w.stop = false;
    while (!w.stop) {
        rb_thread_blocking_region(async_cb_wait, &w, async_cb_stop, &w);
        if (w.cb != NULL) {
            // Start up a new ruby thread to run the ruby callback
            rb_thread_create(async_cb_call, w.cb);
        }
    }
    
    return Qnil;
}

#else
static VALUE
async_cb_event(void* unused)
{
    while (true) {
        struct gvl_callback* cb;
        char buf[64];

        if (read(async_cb_pipe[0], buf, sizeof(buf)) < 0) {
            rb_thread_wait_fd(async_cb_pipe[0]);
            while (read(async_cb_pipe[0], buf, sizeof (buf)) < 0) {
                if (rb_io_wait_readable(async_cb_pipe[0]) != Qtrue) {
                    return Qfalse;
                }
            }
        }

        pthread_mutex_lock(&async_cb_mutex);
        cb = async_cb_list;
        async_cb_list = NULL;
        pthread_mutex_unlock(&async_cb_mutex);

        while (cb != NULL) {
            struct gvl_callback* next = cb->next;
            // Start up a new ruby thread to run the ruby callback
            rb_thread_create(async_cb_call, cb);
            cb = next;
        }
    }

    return Qnil;
}
#endif

#ifdef _WIN32
static VALUE
async_cb_wait(void *data)
{
    struct async_wait* w = (struct async_wait *) data;

    w->cb = NULL;

    EnterCriticalSection(&async_cb_lock);

    while (!w->stop && async_cb_list == NULL) {
        LeaveCriticalSection(&async_cb_lock);
        WaitForSingleObject(async_cb_cond, INFINITE);
        EnterCriticalSection(&async_cb_lock);
    }
    
    if (async_cb_list != NULL) {
        w->cb = async_cb_list;
        async_cb_list = async_cb_list->next;
    }

    LeaveCriticalSection(&async_cb_lock);
    
    return Qnil;
}

static void
async_cb_stop(void *data)
{
    struct async_wait* w = (struct async_wait *) data;

    EnterCriticalSection(&async_cb_lock);
    w->stop = true;
    LeaveCriticalSection(&async_cb_lock);
    SetEvent(async_cb_cond);
}

#else
static VALUE
async_cb_wait(void *data)
{
    struct async_wait* w = (struct async_wait *) data;

    w->cb = NULL;

    pthread_mutex_lock(&async_cb_mutex);

    while (!w->stop && async_cb_list == NULL) {
        pthread_cond_wait(&async_cb_cond, &async_cb_mutex);
    }
    
    if (async_cb_list != NULL) {
        w->cb = async_cb_list;
        async_cb_list = async_cb_list->next;
    }

    pthread_mutex_unlock(&async_cb_mutex);
    
    return Qnil;
}

static void
async_cb_stop(void *data)
{
    struct async_wait* w = (struct async_wait *) data;

    pthread_mutex_lock(&async_cb_mutex);
    w->stop = true;
    pthread_cond_signal(&async_cb_cond);
    pthread_mutex_unlock(&async_cb_mutex);
}
#endif

static VALUE
async_cb_call(void *data)
{
    struct gvl_callback* cb = (struct gvl_callback *) data;

    callback_with_gvl(cb);

    // Signal the original native thread that the ruby code has completed
#ifdef _WIN32
    SetEvent(cb->async_event);
#else
    pthread_mutex_lock(&cb->async_mutex);
    cb->done = true;
    pthread_cond_signal(&cb->async_cond);
    pthread_mutex_unlock(&cb->async_mutex);
#endif

    return Qnil;
}

#endif


static void*
callback_with_gvl(void* data)
{
    struct gvl_callback* cb = (struct gvl_callback *) data;

    Function* fn = (Function *) cb->closure->info;
    FunctionType *cbInfo = fn->info;
    Type* returnType = cbInfo->returnType;
    void* retval = cb->retval;
    void** parameters = cb->parameters;
    VALUE* rbParams;
    VALUE rbReturnType = cbInfo->rbReturnType;
    VALUE rbReturnValue;
    int i;

    rbParams = ALLOCA_N(VALUE, cbInfo->parameterCount);
    for (i = 0; i < cbInfo->parameterCount; ++i) {
        VALUE param;
        Type* paramType = cbInfo->parameterTypes[i];
        VALUE rbParamType = rb_ary_entry(cbInfo->rbParameterTypes, i);

        if (unlikely(paramType->nativeType == NATIVE_MAPPED)) {
            paramType = ((MappedType *) paramType)->type;
            rbParamType = ((MappedType *) paramType)->rbType;
        }

        switch (paramType->nativeType) {
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
            case NATIVE_STRUCT:
                param = rbffi_NativeValue_ToRuby(paramType, rbParamType, parameters[i]);
                break;

            default:
                param = Qnil;
                break;
        }

        // Convert the native value into a custom ruby value
        if (unlikely(cbInfo->parameterTypes[i]->nativeType == NATIVE_MAPPED)) {
            VALUE values[] = { param, Qnil };
            param = rb_funcall2(((MappedType *) cbInfo->parameterTypes[i])->rbConverter, id_from_native, 2, values);
        }

        rbParams[i] = param;
    }

    rbReturnValue = rb_funcall2(fn->rbProc, id_call, cbInfo->parameterCount, rbParams);
    
    if (unlikely(returnType->nativeType == NATIVE_MAPPED)) {
        VALUE values[] = { rbReturnValue, Qnil };
        rbReturnValue = rb_funcall2(((MappedType *) returnType)->rbConverter, id_to_native, 2, values);
        rbReturnType = ((MappedType *) returnType)->rbType;
        returnType = ((MappedType* ) returnType)->type;
    }

    if (rbReturnValue == Qnil || TYPE(rbReturnValue) == T_NIL) {
        memset(retval, 0, returnType->ffiType->size);
    } else switch (returnType->nativeType) {
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

                function = rbffi_Function_ForProc(rbReturnType, rbReturnValue);

                *((void **) retval) = ((AbstractMemory *) DATA_PTR(function))->address;
            } else {
                *((void **) retval) = NULL;
            }
            break;

        case NATIVE_STRUCT:
            if (TYPE(rbReturnValue) == T_DATA && rb_obj_is_kind_of(rbReturnValue, rbffi_StructClass)) {
                AbstractMemory* memory = ((Struct *) DATA_PTR(rbReturnValue))->pointer;

                if (memory->address != NULL) {
                    memcpy(retval, memory->address, returnType->ffiType->size);

                } else {
                    memset(retval, 0, returnType->ffiType->size);
                }
                
            } else {
                memset(retval, 0, returnType->ffiType->size);
            }
            break;

        default:
            *((ffi_arg *) retval) = 0;
            break;
    }

    return NULL;
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
    rb_define_method(rbffi_FunctionClass, "initialize_copy", function_initialize_copy, 1);
    rb_define_method(rbffi_FunctionClass, "call", function_call, -1);
    rb_define_method(rbffi_FunctionClass, "attach", function_attach, 2);
    rb_define_method(rbffi_FunctionClass, "free", function_release, 0);
    rb_define_method(rbffi_FunctionClass, "autorelease=", function_set_autorelease, 1);
    rb_define_method(rbffi_FunctionClass, "autorelease", function_autorelease_p, 0);
    rb_define_method(rbffi_FunctionClass, "autorelease?", function_autorelease_p, 0);

    id_call = rb_intern("call");
    id_cbtable = rb_intern("@__ffi_callback_table__");
    id_cb_ref = rb_intern("@__ffi_callback__");
    id_to_native = rb_intern("to_native");
    id_from_native = rb_intern("from_native");
#if defined(_WIN32) && defined(HAVE_RB_THREAD_BLOCKING_REGION)
    InitializeCriticalSection(&async_cb_lock);
    async_cb_cond = CreateEvent(NULL, FALSE, FALSE, NULL);
#endif
}

