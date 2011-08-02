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
#else
#  include <windows.h>
#endif
#include <errno.h>
#include <ruby.h>

#include <ffi.h>
#include "rbffi.h"
#include "compat.h"

#include "Function.h"
#include "Types.h"
#include "Type.h"
#include "LastError.h"
#include "Call.h"

#include "ClosurePool.h"


#ifndef roundup
#  define roundup(x, y)   ((((x)+((y)-1))/(y))*(y))
#endif
#ifdef _WIN32
  typedef char* caddr_t;
#endif

typedef struct Memory {
    void* code;
    void* data;
    struct Memory* next;
} Memory;

struct ClosurePool_ {
    void* ctx;
    int closureSize;
    bool (*prep)(void* ctx, void *code, Closure* closure, char* errbuf, size_t errbufsize);
    struct Memory* blocks; /* Keeps track of all the allocated memory for this pool */
    Closure* list;
    long refcnt;
};

static int pageSize;

static void* allocatePage(void);
static bool freePage(void *);
static bool protectPage(void *);

ClosurePool*
rbffi_ClosurePool_New(int closureSize, 
        bool (*prep)(void* ctx, void *code, Closure* closure, char* errbuf, size_t errbufsize),
        void* ctx)
{
    ClosurePool* pool;

    pool = xcalloc(1, sizeof(*pool));
    pool->closureSize = closureSize;
    pool->ctx = ctx;
    pool->prep = prep;
    pool->refcnt = 1;
    
    return pool;
}

void
cleanup_closure_pool(ClosurePool* pool)
{
    Memory* memory;
    
    for (memory = pool->blocks; memory != NULL; ) {
        Memory* next = memory->next;
        freePage(memory->code);
        free(memory->data);
        free(memory);
        memory = next;
    }
    free(pool);
}

void
rbffi_ClosurePool_Free(ClosurePool* pool)
{
    if (pool != NULL) {
        int refcnt;
        refcnt = --(pool->refcnt);
        if (refcnt == 0) {
            cleanup_closure_pool(pool);
        }
    }
}

Closure*
rbffi_Closure_Alloc(ClosurePool* pool)
{
    Closure *list = NULL;
    Memory* block = NULL;
    caddr_t code = NULL;
    char errmsg[256];
    int nclosures, trampolineSize;
    int i;

    if (pool->list != NULL) {
        Closure* closure = pool->list;
        pool->list = pool->list->next;
        pool->refcnt++;
    
        return closure;
    }

    trampolineSize = roundup(pool->closureSize, 8);
    nclosures = pageSize / trampolineSize;
    block = calloc(1, sizeof(*block));
    list = calloc(nclosures, sizeof(*list));
    code = allocatePage();
    
    if (block == NULL || list == NULL || code == NULL) {
        snprintf(errmsg, sizeof(errmsg), "failed to allocate a page. errno=%d (%s)", errno, strerror(errno));
        goto error;
    }
    
    for (i = 0; i < nclosures; ++i) {
        Closure* closure = &list[i];
        closure->next = &list[i + 1];
        closure->pool = pool;
        closure->code = (code + (i * trampolineSize));

        if (!(*pool->prep)(pool->ctx, closure->code, closure, errmsg, sizeof(errmsg))) {
            goto error;
        }
    }

    if (!protectPage(code)) {
        goto error;
    }

    /* Track the allocated page + Closure memory area */
    block->data = list;
    block->code = code;
    block->next = pool->blocks;
    pool->blocks = block;

    /* Thread the new block onto the free list, apart from the first one. */
    list[nclosures - 1].next = pool->list;
    pool->list = list->next;
    pool->refcnt++;

    /* Use the first one as the new handle */
    return list;

error:
    free(block);
    free(list);
    if (code != NULL) {
        freePage(code);
    }
    

    rb_raise(rb_eRuntimeError, "%s", errmsg);
    return NULL;
}

void
rbffi_Closure_Free(Closure* closure)
{
    if (closure != NULL) {
        ClosurePool* pool = closure->pool;
        int refcnt;
        // Just push it on the front of the free list
        closure->next = pool->list;
        pool->list = closure;
        refcnt = --(pool->refcnt);
        if (refcnt == 0) {
            cleanup_closure_pool(pool);
        }
    }
}

void*
rbffi_Closure_CodeAddress(Closure* handle)
{
    return handle->code;
}


static int
getPageSize()
{
#if defined(_WIN32) || defined(__WIN32__)
    SYSTEM_INFO si;
    GetSystemInfo(&si);
    return si.dwPageSize;
#else
    return sysconf(_SC_PAGESIZE);
#endif
}

static void*
allocatePage(void)
{
#if defined(_WIN32) || defined(__WIN32__)
    return VirtualAlloc(NULL, pageSize, MEM_COMMIT | MEM_RESERVE, PAGE_READWRITE);
#else
    caddr_t page = mmap(NULL, pageSize, PROT_READ | PROT_WRITE, MAP_ANON | MAP_PRIVATE, -1, 0);
    return (page != (caddr_t) -1) ? page : NULL;
#endif
}

static bool
freePage(void *addr)
{
#if defined(_WIN32) || defined(__WIN32__)
    return VirtualFree(addr, 0, MEM_RELEASE);
#else
    return munmap(addr, pageSize) == 0;
#endif
}

static bool
protectPage(void* page)
{
#if defined(_WIN32) || defined(__WIN32__)
    DWORD oldProtect;
    return VirtualProtect(page, pageSize, PAGE_EXECUTE_READ, &oldProtect);
#else
    return mprotect(page, pageSize, PROT_READ | PROT_EXEC) == 0;
#endif
}

void
rbffi_ClosurePool_Init(VALUE module)
{
    pageSize = getPageSize();
}

