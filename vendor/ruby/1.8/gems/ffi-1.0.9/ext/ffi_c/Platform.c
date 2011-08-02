/*
 * Copyright (c) 2008-2010 Wayne Meissner
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

#include <sys/param.h>
#include <sys/types.h>
#include <stdint.h>
#include <stdbool.h>
#include <ruby.h>
#include <ctype.h>
#include "endian.h"
#include "Platform.h"

static VALUE PlatformModule = Qnil;

/*
 * Determine the cpu type at compile time - useful for MacOSX where the the
 * system installed ruby incorrectly reports 'host_cpu' as 'powerpc' when running
 * on intel.
 */
#if defined(__x86_64__) || defined(__x86_64) || defined(__amd64)
# define CPU "x86_64"

#elif defined(__i386__) || defined(__i386)
# define CPU "i386"

#elif defined(__ppc64__) || defined(__powerpc64__)
# define CPU "ppc64"

#elif defined(__ppc__) || defined(__powerpc__) || defined(__powerpc)
# define CPU "ppc"

/* Need to check for __sparcv9 first, because __sparc will be defined either way. */
#elif defined(__sparcv9__) || defined(__sparcv9)
# define CPU "sparcv9"

#elif defined(__sparc__) || defined(__sparc)
# define CPU "sparc"

#elif defined(__arm__) || defined(__arm)
# define CPU "arm"

#elif defined(__mips__) || defined(__mips)
# define CPU "mips"

#elif defined(__s390__)
# define CPU "s390"

#else
# define CPU "unknown"
#endif

static void
export_primitive_types(VALUE module)
{
#define S(name, T) do { \
    typedef struct { char c; T v; } s; \
    rb_define_const(module, #name "_ALIGN", INT2NUM((sizeof(s) - sizeof(T)) * 8)); \
    rb_define_const(module, #name "_SIZE", INT2NUM(sizeof(T)* 8)); \
} while(0)
    S(INT8, char);
    S(INT16, short);
    S(INT32, int);
    S(INT64, long long);
    S(LONG, long);
    S(FLOAT, float);
    S(DOUBLE, double);
    S(ADDRESS, void*);
#undef S
}

void
rbffi_Platform_Init(VALUE moduleFFI)
{
    PlatformModule = rb_define_module_under(moduleFFI, "Platform");
    rb_define_const(PlatformModule, "BYTE_ORDER", INT2FIX(BYTE_ORDER));
    rb_define_const(PlatformModule, "LITTLE_ENDIAN", INT2FIX(LITTLE_ENDIAN));
    rb_define_const(PlatformModule, "BIG_ENDIAN", INT2FIX(BIG_ENDIAN));
    rb_define_const(PlatformModule, "CPU", rb_str_new2(CPU));
    export_primitive_types(PlatformModule);
}

