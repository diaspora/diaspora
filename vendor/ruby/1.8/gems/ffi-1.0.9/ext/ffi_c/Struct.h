/*
 * Copyright (c) 2008, 2009, Wayne Meissner
 * Copyright (c) 2009, Luc Heinrich <luc@honk-honk.com>
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

#ifndef RBFFI_STRUCT_H
#define	RBFFI_STRUCT_H

#include "AbstractMemory.h"
#include "Type.h"
#ifdef RUBY_1_9
#include <ruby/st.h>
#else
#include <st.h>
#endif

#ifdef	__cplusplus
extern "C" {
#endif

    extern void rbffi_Struct_Init(VALUE ffiModule);
    extern void rbffi_StructLayout_Init(VALUE ffiModule);
    typedef struct StructField_ StructField;
    typedef struct StructLayout_ StructLayout;
    typedef struct Struct_ Struct;

    struct StructField_ {
        Type* type;
        unsigned int offset;

        int referenceIndex;

        bool referenceRequired;
        VALUE rbType;
        VALUE rbName;

        VALUE (*get)(StructField* field, Struct* s);
        void (*put)(StructField* field, Struct* s, VALUE value);

        MemoryOp* memoryOp;
    };

    struct StructLayout_ {
        Type base;
        StructField** fields;
        unsigned int fieldCount;
        int size;
        int align;
        ffi_type** ffiTypes;
        struct st_table* fieldSymbolTable;

        /** The number of reference tracking fields in this struct */
        int referenceFieldCount;
        
        VALUE rbFieldNames;
        VALUE rbFieldMap;
        VALUE rbFields;
    };

    struct Struct_ {
        StructLayout* layout;
        AbstractMemory* pointer;
        VALUE* rbReferences;

        VALUE rbLayout;
        VALUE rbPointer;
    };

    extern VALUE rbffi_StructClass, rbffi_StructLayoutClass;
    extern VALUE rbffi_StructLayoutFieldClass, rbffi_StructLayoutFunctionFieldClass;
    extern VALUE rbffi_StructLayoutArrayFieldClass;
    extern VALUE rbffi_StructInlineArrayClass;
    extern VALUE rbffi_StructLayoutCharArrayClass;

#ifdef	__cplusplus
}
#endif

#endif	/* RBFFI_STRUCT_H */

