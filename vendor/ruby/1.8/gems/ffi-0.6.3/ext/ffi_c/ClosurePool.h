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

