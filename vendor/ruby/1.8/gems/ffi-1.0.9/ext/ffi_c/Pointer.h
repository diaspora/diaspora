/*
 * Copyright (c) 2008, 2009, Wayne Meissner
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

#ifndef RBFFI_POINTER_H
#define	RBFFI_POINTER_H

#include <stdbool.h>

#ifdef	__cplusplus
extern "C" {
#endif

#include "AbstractMemory.h"

extern void rbffi_Pointer_Init(VALUE moduleFFI);
extern VALUE rbffi_Pointer_NewInstance(void* addr);
extern VALUE rbffi_PointerClass;
extern VALUE rbffi_NullPointerSingleton;

typedef struct Pointer {
    AbstractMemory memory;
    VALUE rbParent;
    char* storage; /* start of malloc area */
    bool autorelease;
    bool allocated;
} Pointer;

#ifdef	__cplusplus
}
#endif

#endif	/* RBFFI_POINTER_H */

