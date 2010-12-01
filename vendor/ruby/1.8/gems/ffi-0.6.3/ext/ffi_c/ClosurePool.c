/*
 * Copyright (c) 2009, Wayne Meissner
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
#if defined(HAVE_NATIVETHREAD) && !defined(_WIN32) && !defined(__WIN32__)
# include <pthread.h>
#endif

#include <ffi.h>
#include "rbffi.h"
#include "compat.h"

#include "Function.h"
#include "Types.h"
#include "Type.h"
#include "LastError.h"
#include "Call.h"

#include "ClosurePool.h"


#if defined(HAVE_NATIVETHREAD) && !defined(_WIN32) && !defined(__WIN32__)
#  define USE_PTHREAD_LOCAL
#endif

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
#if defined (HAVE_NATIVETHREAD) && !defined(_WIN32)
    pthread_mutex_t mutex;
#endif
    struct Memory* blocks; /* Keeps track of all the allocated memory for this pool */
    Closure* list;
    long refcnt;
};

#if defined(HAVE_NATIVETHREAD) && !defined(_WIN32)
#  define pool_lock(p) pthread_mutex_lock(&(p)->mutex)
#  define pool_unlock(p)  pthread_mutex_unlock(&(p)->mutex)
#else
#  define pool_lock(p)
#  define pool_unlock(p)
#endif

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
    
#if defined(HAVE_NATIVETHREAD) && !defined(_WIN32)
    pthread_mutex_init(&pool->mutex, NULL);
#endif

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
        pool_lock(pool);
        refcnt = --(pool->refcnt);
        pool_unlock(pool);

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

    pool_lock(pool);
    if (pool->list != NULL) {
        Closure* closure = pool->list;
        pool->list = pool->list->next;
        pool->refcnt++;
        pool_unlock(pool);

        return closure;
    }

    trampolineSize = roundup(pool->closureSize, 8);
    nclosures = pageSize / trampolineSize;
    block = calloc(1, sizeof(*block));
    list = calloc(nclosures, sizeof(*list));
    code = allocatePage();
    
    if (block == NULL || list == NULL || code == NULL) {
        pool_unlock(pool);
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

    pool_unlock(pool);

    /* Use the first one as the new handle */
    return list;

error:
    pool_unlock(pool);
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
        pool_lock(pool);
        // Just push it on the front of the free list
        closure->next = pool->list;
        pool->list = closure;
        refcnt = --(pool->refcnt);
        pool_unlock(pool);

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

