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

#ifndef RBFFI_COMPAT_H
#define RBFFI_COMPAT_H

#include <ruby.h>

#ifndef RARRAY_LEN
#  define RARRAY_LEN(ary) RARRAY(ary)->len
#endif

#ifndef RARRAY_PTR
#  define RARRAY_PTR(ary) RARRAY(ary)->ptr
#endif

#ifndef RSTRING_LEN
#  define RSTRING_LEN(s) RSTRING(s)->len
#endif

#ifndef RSTRING_PTR
#  define RSTRING_PTR(s) RSTRING(s)->ptr
#endif

#ifndef NUM2ULL
#  define NUM2ULL(x) rb_num2ull((VALUE)x)
#endif

#ifndef roundup
#  define roundup(x, y)   ((((x)+((y)-1))/(y))*(y))
#endif

#ifdef __GNUC__
#  define likely(x) __builtin_expect((x), 1)
#  define unlikely(x) __builtin_expect((x), 0)
#else
#  define likely(x) (x)
#  define unlikely(x) (x)
#endif

#ifndef MAX
#  define MAX(a, b) ((a) < (b) ? (b) : (a))
#endif
#ifndef MIN
#  define MIN(a, b) ((a) < (b) ? (a) : (b))
#endif

#endif /* RBFFI_COMPAT_H */

