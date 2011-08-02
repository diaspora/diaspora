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

#ifndef RUBYFFI_CLOSUREPOOL_H
#define RUBYFFI_CLOSUREPOOL_H

typedef struct ClosurePool_ ClosurePool;
typedef struct Closure_ Closure;

struct Closure_ {
    void* info;      /* opaque handle for storing closure-instance specific data */
    void* function;  /* closure-instance specific function, called by custom trampoline */
    void* code;      /* The native trampoline code location */
    struct ClosurePool_* pool;
    Closure* next;
};

void rbffi_ClosurePool_Init(VALUE module);

ClosurePool* rbffi_ClosurePool_New(int closureSize, 
        bool (*prep)(void* ctx, void *code, Closure* closure, char* errbuf, size_t errbufsize),
        void* ctx);

void rbffi_ClosurePool_Free(ClosurePool *);

Closure* rbffi_Closure_Alloc(ClosurePool *);
void rbffi_Closure_Free(Closure *);

void* rbffi_Closure_GetCodeAddress(Closure *);

#endif /* RUBYFFI_CLOSUREPOOL_H */

