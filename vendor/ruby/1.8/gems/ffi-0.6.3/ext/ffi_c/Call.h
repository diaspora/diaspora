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

extern void rbffi_SetupCallParams(int argc, VALUE* argv, int paramCount, NativeType* paramTypes,
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

