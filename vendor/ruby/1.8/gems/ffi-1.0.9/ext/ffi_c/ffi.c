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

#include <sys/types.h>
#include <stdio.h>
#include <ruby.h>

#include <ffi.h>

#include "rbffi.h"
#include "AbstractMemory.h"
#include "Pointer.h"
#include "MemoryPointer.h"
#include "Struct.h"
#include "StructByValue.h"
#include "StructByReference.h"
#include "DynamicLibrary.h"
#include "Platform.h"
#include "Types.h"
#include "LastError.h"
#include "Function.h"
#include "ClosurePool.h"
#include "MethodHandle.h"
#include "Call.h"
#include "ArrayType.h"
#include "MappedType.h"

void Init_ffi_c(void);

VALUE rbffi_FFIModule = Qnil;

static VALUE moduleFFI = Qnil;

void
Init_ffi_c(void) {
    rbffi_FFIModule = moduleFFI = rb_define_module("FFI");
    rb_global_variable(&moduleFFI);


    // FFI::Type needs to be initialized before most other classes
    rbffi_Type_Init(moduleFFI);

    rbffi_DataConverter_Init(moduleFFI);

    rbffi_ArrayType_Init(moduleFFI);
    rbffi_LastError_Init(moduleFFI);
    rbffi_Call_Init(moduleFFI);
    rbffi_ClosurePool_Init(moduleFFI);
    rbffi_MethodHandle_Init(moduleFFI);
    rbffi_Platform_Init(moduleFFI);
    rbffi_AbstractMemory_Init(moduleFFI);
    rbffi_Pointer_Init(moduleFFI);
    rbffi_Function_Init(moduleFFI);
    rbffi_MemoryPointer_Init(moduleFFI);
    rbffi_Buffer_Init(moduleFFI);
    rbffi_StructByValue_Init(moduleFFI);
    rbffi_StructByReference_Init(moduleFFI);
    rbffi_Struct_Init(moduleFFI);
    rbffi_DynamicLibrary_Init(moduleFFI);
    rbffi_Variadic_Init(moduleFFI);
    rbffi_Types_Init(moduleFFI);
    rbffi_MappedType_Init(moduleFFI);
}

