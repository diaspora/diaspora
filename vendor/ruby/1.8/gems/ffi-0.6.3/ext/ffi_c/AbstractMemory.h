/*
 * Copyright (c) 2008, 2009, Wayne Meissner
 *
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

#ifndef RBFFI_ABSTRACTMEMORY_H
#define	RBFFI_ABSTRACTMEMORY_H

#include <sys/param.h>
#include <sys/types.h>
#include <stdint.h>

#include "compat.h"
#include "Types.h"

#ifdef	__cplusplus
extern "C" {
#endif


#define MEM_RD   0x01
#define MEM_WR   0x02
#define MEM_CODE 0x04

typedef struct AbstractMemory_ AbstractMemory;

typedef struct {
    VALUE (*get)(AbstractMemory* ptr, long offset);
    void (*put)(AbstractMemory* ptr, long offset, VALUE value);
} MemoryOp;

typedef struct {
    MemoryOp* int8;
    MemoryOp* uint8;
    MemoryOp* int16;
    MemoryOp* uint16;
    MemoryOp* int32;
    MemoryOp* uint32;
    MemoryOp* int64;
    MemoryOp* uint64;
    MemoryOp* slong;
    MemoryOp* ulong;
    MemoryOp* float32;
    MemoryOp* float64;
    MemoryOp* pointer;
    MemoryOp* strptr;
} MemoryOps;

struct AbstractMemory_ {
    char* address; // Use char* instead of void* to ensure adding to it works correctly
    long size;
    int access;
    int typeSize;
};


extern VALUE rbffi_AbstractMemoryClass;
extern MemoryOps rbffi_AbstractMemoryOps;

extern void rbffi_AbstractMemory_Init(VALUE ffiModule);

extern AbstractMemory* rbffi_AbstractMemory_Cast(VALUE obj, VALUE klass);

extern void rbffi_AbstractMemory_Error(AbstractMemory *, int op);

static inline void
checkBounds(AbstractMemory* mem, long off, long len)
{
    if (unlikely((off | len | (off + len) | (mem->size - (off + len))) < 0)) {
        rb_raise(rb_eIndexError, "Memory access offset=%ld size=%ld is out of bounds",
                off, len);
    }
}

static inline void
checkRead(AbstractMemory* mem)
{
    if (unlikely((mem->access & MEM_RD) == 0)) {
        rbffi_AbstractMemory_Error(mem, MEM_RD);
    }
}

static inline void
checkWrite(AbstractMemory* mem)
{
    if (unlikely((mem->access & MEM_WR) == 0)) {
        rbffi_AbstractMemory_Error(mem, MEM_WR);
    }
}

static inline MemoryOp*
get_memory_op(Type* type)
{
    switch (type->nativeType) {
        case NATIVE_INT8:
            return rbffi_AbstractMemoryOps.int8;
        case NATIVE_UINT8:
            return rbffi_AbstractMemoryOps.uint8;
        case NATIVE_INT16:
            return rbffi_AbstractMemoryOps.int16;
        case NATIVE_UINT16:
            return rbffi_AbstractMemoryOps.uint16;
        case NATIVE_INT32:
            return rbffi_AbstractMemoryOps.int32;
        case NATIVE_UINT32:
            return rbffi_AbstractMemoryOps.uint32;
        case NATIVE_INT64:
            return rbffi_AbstractMemoryOps.int64;
        case NATIVE_UINT64:
            return rbffi_AbstractMemoryOps.uint64;
        case NATIVE_LONG:
            return rbffi_AbstractMemoryOps.slong;
        case NATIVE_ULONG:
            return rbffi_AbstractMemoryOps.ulong;
        case NATIVE_FLOAT32:
            return rbffi_AbstractMemoryOps.float32;
        case NATIVE_FLOAT64:
            return rbffi_AbstractMemoryOps.float64;
        case NATIVE_POINTER:
            return rbffi_AbstractMemoryOps.pointer;
        case NATIVE_STRING:
            return rbffi_AbstractMemoryOps.strptr;
        default:
            return NULL;
    }
}

#define MEMORY(obj) rbffi_AbstractMemory_Cast((obj), rbffi_AbstractMemoryClass)
#define MEMORY_PTR(obj) MEMORY((obj))->address
#define MEMORY_LEN(obj) MEMORY((obj))->size



#ifdef	__cplusplus
}
#endif

#endif	/* RBFFI_ABSTRACTMEMORY_H */

