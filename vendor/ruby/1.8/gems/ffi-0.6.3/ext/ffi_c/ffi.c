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

#include <sys/types.h>
#include <stdio.h>
#include <ruby.h>

#include <ffi.h>

#include "rbffi.h"
#include "AbstractMemory.h"
#include "Pointer.h"
#include "MemoryPointer.h"
#include "AutoPointer.h"
#include "Struct.h"
#include "StructByValue.h"
#include "DynamicLibrary.h"
#include "Platform.h"
#include "Types.h"
#include "LastError.h"
#include "Function.h"
#include "ClosurePool.h"
#include "MethodHandle.h"
#include "Call.h"
#include "ArrayType.h"

void Init_ffi_c(void);

VALUE rbffi_FFIModule = Qnil;

static VALUE moduleFFI = Qnil;

void
Init_ffi_c(void) {
    rbffi_FFIModule = moduleFFI = rb_define_module("FFI");
    rb_global_variable(&moduleFFI);

    // FFI::Type needs to be initialized before most other classes
    rbffi_Type_Init(moduleFFI);
    rbffi_ArrayType_Init(moduleFFI);
    rbffi_LastError_Init(moduleFFI);
    rbffi_Call_Init(moduleFFI);
    rbffi_ClosurePool_Init(moduleFFI);
    rbffi_MethodHandle_Init(moduleFFI);
    rbffi_Platform_Init(moduleFFI);
    rbffi_AbstractMemory_Init(moduleFFI);
    rbffi_Pointer_Init(moduleFFI);
    rbffi_AutoPointer_Init(moduleFFI);
    rbffi_Function_Init(moduleFFI);
    rbffi_MemoryPointer_Init(moduleFFI);
    rbffi_Buffer_Init(moduleFFI);
    rbffi_StructByValue_Init(moduleFFI);
    rbffi_Struct_Init(moduleFFI);
    rbffi_DynamicLibrary_Init(moduleFFI);
    rbffi_Variadic_Init(moduleFFI);
    rbffi_Types_Init(moduleFFI);
}

