
#ifndef _MEMORYPOINTER_H
#define	_MEMORYPOINTER_H

#include <stdbool.h>
#include <ruby.h>

#ifdef	__cplusplus
extern "C" {
#endif

    extern void rbffi_MemoryPointer_Init(VALUE moduleFFI);
    extern VALUE rbffi_MemoryPointerClass;
    extern VALUE rbffi_MemoryPointer_NewInstance(long size, long count, bool clear);
#ifdef	__cplusplus
}
#endif

#endif	/* _MEMORYPOINTER_H */

