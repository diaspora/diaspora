/*
 * Copyright (c) 2009, Wayne Meissner
 * Copyright (c) 2009, Luc Heinrich <luc@honk-honk.com>
 * Copyright (c) 2009, Mike Dalessio <mike.dalessio@gmail.com>
 * Copyright (c) 2009, Aman Gupta.
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

#ifndef RBFFI_INVOKE_H
#define	RBFFI_INVOKE_H

#ifdef	__cplusplus
extern "C" {
#endif

#if defined(__i386__) && \
  (defined(HAVE_RAW_API) || defined(USE_INTERNAL_LIBFFI)) && \
  !defined(_WIN32) && !defined(__WIN32__)
#  define USE_RAW
#endif

#if (defined(__i386__) || defined(__x86_64__)) && !(defined(_WIN32) || defined(__WIN32__))
#  define BYPASS_FFI 1
#endif
    
typedef union {
#ifdef USE_RAW
    signed int s8, s16, s32;
    unsigned int u8, u16, u32;
#else
    signed char s8;
    unsigned char u8;
    signed short s16;
    unsigned short u16;
    signed int s32;
    unsigned int u32;
#endif
    signed long long i64;
    unsigned long long u64;
    signed long sl;
    unsigned long ul;
    void* ptr;
    float f32;
    double f64;
} FFIStorage;


extern void rbffi_Call_Init(VALUE moduleFFI);

extern void rbffi_SetupCallParams(int argc, VALUE* argv, int paramCount, Type** paramTypes,
        FFIStorage* paramStorage, void** ffiValues,
        VALUE* callbackParameters, int callbackCount, VALUE enums);

extern VALUE rbffi_CallFunction(int argc, VALUE* argv, void* function, FunctionType* fnInfo);

typedef VALUE (*Invoker)(int argc, VALUE* argv, void* function, FunctionType* fnInfo);

Invoker rbffi_GetInvoker(FunctionType* fnInfo);

extern VALUE rbffi_GetEnumValue(VALUE enums, VALUE value);
extern int rbffi_GetSignedIntValue(VALUE value, int type, int minValue, int maxValue, const char* typeName, VALUE enums);

#ifdef	__cplusplus
}
#endif

#endif	/* RBFFI_INVOKE_H */

