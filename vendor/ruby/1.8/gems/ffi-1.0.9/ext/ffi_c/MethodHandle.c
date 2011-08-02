/*
 * Copyright (c) 2009, 2010 Wayne Meissner
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
#ifndef _WIN32
#  include <sys/mman.h>
#endif
#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#ifndef _WIN32
#  include <unistd.h>
#endif
#include <errno.h>
#include <ruby.h>
#if defined(HAVE_NATIVETHREAD) && !defined(_WIN32) && !defined(__WIN32__)
# include <pthread.h>
#endif

#include <ffi.h>
#include "rbffi.h"
#include "compat.h"

#include "Function.h"
#include "Types.h"
#include "Type.h"
#include "LastError.h"
#include "Call.h"
#include "ClosurePool.h"
#include "MethodHandle.h"


#define MAX_METHOD_FIXED_ARITY (6)

#ifndef roundup
#  define roundup(x, y)   ((((x)+((y)-1))/(y))*(y))
#endif
#ifdef _WIN32
  typedef char* caddr_t;
#endif

#ifdef USE_RAW
#  define METHOD_CLOSURE ffi_raw_closure
#  define METHOD_PARAMS ffi_raw*
#else
#  define METHOD_CLOSURE ffi_closure
#  define METHOD_PARAMS void**
#endif



static bool prep_trampoline(void* ctx, void* code, Closure* closure, char* errmsg, size_t errmsgsize);
static int trampoline_size(void);

#if defined(__x86_64__) && defined(__GNUC__)
# define CUSTOM_TRAMPOLINE 1
#endif


struct MethodHandle {
    Closure* closure;
};

static ClosurePool* defaultClosurePool;


MethodHandle*
rbffi_MethodHandle_Alloc(FunctionType* fnInfo, void* function)
{
    MethodHandle* handle;
    Closure* closure = rbffi_Closure_Alloc(defaultClosurePool);
    if (closure == NULL) {
        rb_raise(rb_eNoMemError, "failed to allocate closure from pool");
        return NULL;
    }

    handle = xcalloc(1, sizeof(*handle));
    handle->closure = closure;
    closure->info = fnInfo;
    closure->function = function;

    return handle;
}

void
rbffi_MethodHandle_Free(MethodHandle* handle)
{
    if (handle != NULL) {
        rbffi_Closure_Free(handle->closure);
    }
}

void*
rbffi_MethodHandle_CodeAddress(MethodHandle* handle)
{
    return handle->closure->code;
}

#ifndef CUSTOM_TRAMPOLINE
static void attached_method_invoke(ffi_cif* cif, void* retval, METHOD_PARAMS parameters, void* user_data);

static ffi_type* methodHandleParamTypes[] = {
    &ffi_type_sint,
    &ffi_type_pointer,
    &ffi_type_ulong,
};

static ffi_cif mh_cif;

static bool
prep_trampoline(void* ctx, void* code, Closure* closure, char* errmsg, size_t errmsgsize)
{
    ffi_status ffiStatus;

#if defined(USE_RAW)
    ffiStatus = ffi_prep_raw_closure(code, &mh_cif, attached_method_invoke, closure);
#else
    ffiStatus = ffi_prep_closure(code, &mh_cif, attached_method_invoke, closure);
#endif
    if (ffiStatus != FFI_OK) {
        snprintf(errmsg, errmsgsize, "ffi_prep_closure failed.  status=%#x", ffiStatus);
        return false;
    }

    return true;
}


static int
trampoline_size(void)
{
    return sizeof(METHOD_CLOSURE);
}

/*
 * attached_method_vinvoke is used functions with more than 6 parameters, or
 * with struct param or return values
 */
static void
attached_method_invoke(ffi_cif* cif, void* mretval, METHOD_PARAMS parameters, void* user_data)
{
    Closure* handle =  (Closure *) user_data;
    FunctionType* fnInfo = (FunctionType *) handle->info;

#ifdef USE_RAW
    int argc = parameters[0].sint;
    VALUE* argv = *(VALUE **) &parameters[1];
#else
    int argc = *(int *) parameters[0];
    VALUE* argv = *(VALUE **) parameters[1];
#endif

    *(VALUE *) mretval = (*fnInfo->invoke)(argc, argv, handle->function, fnInfo);
}

#endif



#if defined(CUSTOM_TRAMPOLINE)
#if defined(__x86_64__)

static VALUE custom_trampoline(int argc, VALUE* argv, VALUE self, Closure*);

#define TRAMPOLINE_CTX_MAGIC (0xfee1deadcafebabe)
#define TRAMPOLINE_FUN_MAGIC (0xfeedfacebeeff00d)

/*
 * This is a hand-coded trampoline to speedup entry from ruby to the FFI translation
 * layer for x86_64 arches.
 *
 * Since a ruby function has exactly 3 arguments, and the first 6 arguments are
 * passed in registers for x86_64, we can tack on a context pointer by simply
 * putting a value in %rcx, then jumping to the C trampoline code.
 *
 * This results in approx a 30% speedup for x86_64 FFI dispatch
 */
asm(
    ".text\n\t"
    ".globl ffi_trampoline\n\t"
    ".globl _ffi_trampoline\n\t"
    "ffi_trampoline:\n\t"
    "_ffi_trampoline:\n\t"
    "movabsq $0xfee1deadcafebabe, %rcx\n\t"
    "movabsq $0xfeedfacebeeff00d, %r11\n\t"
    "jmpq *%r11\n\t"
    ".globl ffi_trampoline_end\n\t"
    "ffi_trampoline_end:\n\t"
    ".globl _ffi_trampoline_end\n\t"
    "_ffi_trampoline_end:\n\t"
);

static VALUE
custom_trampoline(int argc, VALUE* argv, VALUE self, Closure* handle)
{
    FunctionType* fnInfo = (FunctionType *) handle->info;
    return (*fnInfo->invoke)(argc, argv, handle->function, fnInfo);
}

#elif defined(__i386__) && 0

static VALUE custom_trampoline(caddr_t args, Closure*);
#define TRAMPOLINE_CTX_MAGIC (0xfee1dead)
#define TRAMPOLINE_FUN_MAGIC (0xbeefcafe)

/*
 * This is a hand-coded trampoline to speedup entry from ruby to the FFI translation
 * layer for i386 arches.
 *
 * This does not make a discernable difference vs a raw closure, so for now,
 * it is not enabled.
 */
asm(
    ".text\n\t"
    ".globl ffi_trampoline\n\t"
    ".globl _ffi_trampoline\n\t"
    "ffi_trampoline:\n\t"
    "_ffi_trampoline:\n\t"
    "subl    $12, %esp\n\t"
    "leal    16(%esp), %eax\n\t"
    "movl    %eax, (%esp)\n\t"
    "movl    $0xfee1dead, 4(%esp)\n\t"
    "movl    $0xbeefcafe, %eax\n\t"
    "call    *%eax\n\t"
    "addl    $12, %esp\n\t"
    "ret\n\t"
    ".globl ffi_trampoline_end\n\t"
    "ffi_trampoline_end:\n\t"
    ".globl _ffi_trampoline_end\n\t"
    "_ffi_trampoline_end:\n\t"
);

static VALUE
custom_trampoline(caddr_t args, Closure* handle)
{
    FunctionType* fnInfo = (FunctionType *) handle->info;
    return (*fnInfo->invoke)(*(int *) args, *(VALUE **) (args + 4), handle->function, fnInfo);
}

#endif /* __x86_64__ else __i386__ */

extern void ffi_trampoline(int argc, VALUE* argv, VALUE self);
extern void ffi_trampoline_end(void);
static int trampoline_offsets(int *, int *);

static int trampoline_ctx_offset, trampoline_func_offset;

static int
trampoline_offset(int off, const long value)
{
    caddr_t ptr;
    for (ptr = (caddr_t) &ffi_trampoline + off; ptr < (caddr_t) &ffi_trampoline_end; ++ptr) {
        if (*(long *) ptr == value) {
            return ptr - (caddr_t) &ffi_trampoline;
        }
    }

    return -1;
}

static int
trampoline_offsets(int* ctxOffset, int* fnOffset)
{
    *ctxOffset = trampoline_offset(0, TRAMPOLINE_CTX_MAGIC);
    if (*ctxOffset == -1) {
        return -1;
    }

    *fnOffset = trampoline_offset(0, TRAMPOLINE_FUN_MAGIC);
    if (*fnOffset == -1) {
        return -1;
    }

    return 0;
}

static bool
prep_trampoline(void* ctx, void* code, Closure* closure, char* errmsg, size_t errmsgsize)
{
    caddr_t ptr = (caddr_t) code;

    memcpy(ptr, &ffi_trampoline, trampoline_size());
    // Patch the context and function addresses into the stub code
    *(intptr_t *)(ptr + trampoline_ctx_offset) = (intptr_t) closure;
    *(intptr_t *)(ptr + trampoline_func_offset) = (intptr_t) custom_trampoline;

    return true;
}

static int
trampoline_size(void)
{
    return (caddr_t) &ffi_trampoline_end - (caddr_t) &ffi_trampoline;
}

#endif /* CUSTOM_TRAMPOLINE */


void
rbffi_MethodHandle_Init(VALUE module)
{
    defaultClosurePool = rbffi_ClosurePool_New(trampoline_size(), prep_trampoline, NULL);

#if defined(CUSTOM_TRAMPOLINE)
    if (trampoline_offsets(&trampoline_ctx_offset, &trampoline_func_offset) != 0) {
        rb_raise(rb_eFatal, "Could not locate offsets in trampoline code");
    }
#else
    ffi_status ffiStatus = ffi_prep_cif(&mh_cif, FFI_DEFAULT_ABI, 3, &ffi_type_ulong,
            methodHandleParamTypes);
    if (ffiStatus != FFI_OK) {
        rb_raise(rb_eFatal, "ffi_prep_cif failed.  status=%#x", ffiStatus);
    }

#endif
}

