/*
 * Copyright (c) 2008, 2009, Wayne Meissner
 * Copyright (c) 2008, Luc Heinrich <luc@honk-honk.com>
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

#ifndef RBFFI_MEMORYPOINTER_H
#define	RBFFI_MEMORYPOINTER_H

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

#endif	/* RBFFI_MEMORYPOINTER_H */

