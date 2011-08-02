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

#ifndef RBFFI_METHODHANDLE_H
#define	RBFFI_METHODHANDLE_H

#ifdef	__cplusplus
extern "C" {
#endif

#include <ruby.h>
#include "Function.h"

    
typedef struct MethodHandlePool MethodHandlePool;
typedef struct MethodHandle MethodHandle;


MethodHandle* rbffi_MethodHandle_Alloc(FunctionType* fnInfo, void* function);
void rbffi_MethodHandle_Free(MethodHandle* handle);
void* rbffi_MethodHandle_CodeAddress(MethodHandle* handle);
void rbffi_MethodHandle_Init(VALUE module);

#ifdef	__cplusplus
}
#endif

#endif	/* RBFFI_METHODHANDLE_H */

