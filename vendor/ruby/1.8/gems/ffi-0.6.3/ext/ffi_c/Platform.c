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
#ifdef __i386__
#define CPU "i386"
#elif defined(__ppc__) || defined(__powerpc__)
#define CPU "powerpc"
#elif defined(__x86_64__)
#define CPU "x86_64"
#elif defined(__sparc__)
#define CPU "sparc"
#elif defined(__sparcv9__)
#define CPU "sparcv9"
#else
#error "Unknown cpu type"
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
