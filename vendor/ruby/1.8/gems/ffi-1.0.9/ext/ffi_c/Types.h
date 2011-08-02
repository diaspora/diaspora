/*
 * Copyright (c) 2008, 2009, Wayne Meissner
 * Copyright (c) 2009, Luc Heinrich <luc@honk-honk.com>
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

#ifndef RBFFI_TYPES_H
#define	RBFFI_TYPES_H

#ifdef	__cplusplus
extern "C" {
#endif

typedef enum {
    NATIVE_VOID,
    NATIVE_INT8,
    NATIVE_UINT8,
    NATIVE_INT16,
    NATIVE_UINT16,
    NATIVE_INT32,
    NATIVE_UINT32,
    NATIVE_INT64,
    NATIVE_UINT64,
    NATIVE_LONG,
    NATIVE_ULONG,
    NATIVE_FLOAT32,
    NATIVE_FLOAT64,
    NATIVE_POINTER,
    NATIVE_CALLBACK,
    NATIVE_FUNCTION,
    NATIVE_BUFFER_IN,
    NATIVE_BUFFER_OUT,
    NATIVE_BUFFER_INOUT,
    NATIVE_CHAR_ARRAY,
    NATIVE_BOOL,
    
    /** An immutable string.  Nul terminated, but only copies in to the native function */
    NATIVE_STRING,
    
    /** The function takes a variable number of arguments */
    NATIVE_VARARGS,
    
    /** Struct-by-value param or result */
    NATIVE_STRUCT,

    /** An array type definition */
    NATIVE_ARRAY,

    /** Custom native type */
    NATIVE_MAPPED,
} NativeType;

#include <ffi.h>
#include "Type.h"

VALUE rbffi_NativeValue_ToRuby(Type* type, VALUE rbType, const void* ptr);
void rbffi_Types_Init(VALUE moduleFFI);

#ifdef	__cplusplus
}
#endif

#endif	/* RBFFI_TYPES_H */

