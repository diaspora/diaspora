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

#ifndef RBFFI_RBFFI_H
#define	RBFFI_RBFFI_H

#include <ruby.h>

#ifdef	__cplusplus
extern "C" {
#endif

#define MAX_PARAMETERS (32)

extern VALUE rbffi_FFIModule;
    
extern void rbffi_Type_Init(VALUE ffiModule);
extern void rbffi_Buffer_Init(VALUE ffiModule);
extern void rbffi_Invoker_Init(VALUE ffiModule);
extern void rbffi_Variadic_Init(VALUE ffiModule);
extern void rbffi_DataConverter_Init(VALUE ffiModule);
extern VALUE rbffi_AbstractMemoryClass, rbffi_InvokerClass;
extern int rbffi_type_size(VALUE type);

#ifdef	__cplusplus
}
#endif

#endif	/* RBFFI_RBFFI_H */

