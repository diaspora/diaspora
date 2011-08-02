/*
 * Copyright (c) 2009, Wayne Meissner
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

#ifndef RBFFI_FUNCTION_H
#define	RBFFI_FUNCTION_H

#ifdef	__cplusplus
extern "C" {
#endif

#include <stdbool.h>
#include <ffi.h>

typedef struct FunctionType_ FunctionType;

#include "Type.h"
#include "Call.h"
#include "ClosurePool.h"

struct FunctionType_ {
    Type type; // The native type of a FunctionInfo object
    VALUE rbReturnType;
    VALUE rbParameterTypes;

    Type* returnType;
    Type** parameterTypes;
    NativeType* nativeParameterTypes;
    ffi_type* ffiReturnType;
    ffi_type** ffiParameterTypes;
    ffi_cif ffi_cif;
    Invoker invoke;
    ClosurePool* closurePool;
    int parameterCount;
    int flags;
    ffi_abi abi;
    int callbackCount;
    VALUE* callbackParameters;
    VALUE rbEnums;
    bool ignoreErrno;
    bool blocking;
    bool hasStruct;
};

extern VALUE rbffi_FunctionTypeClass, rbffi_FunctionClass;

void rbffi_Function_Init(VALUE moduleFFI);
VALUE rbffi_Function_NewInstance(VALUE functionInfo, VALUE proc);
VALUE rbffi_Function_ForProc(VALUE cbInfo, VALUE proc);
void rbffi_FunctionInfo_Init(VALUE moduleFFI);

#ifdef	__cplusplus
}
#endif

#endif	/* RBFFI_FUNCTION_H */

