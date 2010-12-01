#include <sys/types.h>
#include <stdio.h>
#include <stdint.h>
#if defined(_WIN32) || defined(__WIN32__)
# include <windows.h>
#else
# include <dlfcn.h>
#endif
#include <ruby.h>

#include <ffi.h>

#include "rbffi.h"
#include "compat.h"
#include "AbstractMemory.h"
#include "Pointer.h"
#include "DynamicLibrary.h"

typedef struct LibrarySymbol_ {
    AbstractMemory memory;
    VALUE library;
    VALUE name;
} LibrarySymbol;

static VALUE library_initialize(VALUE self, VALUE libname, VALUE libflags);
static void library_free(Library* lib);


static VALUE symbol_allocate(VALUE klass);
static VALUE symbol_new(VALUE library, void* address, VALUE name);
static void symbol_mark(LibrarySymbol* sym);

static VALUE LibraryClass = Qnil, SymbolClass = Qnil;

#if defined(_WIN32) || defined(__WIN32__)
static void* dl_open(const char* name, int flags);
static void dl_error(char* buf, int size);
#define dl_sym(handle, name) GetProcAddress(handle, name)
#define dl_close(handle) FreeLibrary(handle)
enum { RTLD_LAZY=1, RTLD_NOW, RTLD_GLOBAL, RTLD_LOCAL };
#else
# define dl_open(name, flags) dlopen(name, flags != 0 ? flags : RTLD_LAZY)
# define dl_error(buf, size) do { snprintf(buf, size, "%s", dlerror()); } while(0)
# define dl_sym(handle, name) dlsym(handle, name)
# define dl_close(handle) dlclose(handle)
#ifndef RTLD_LOCAL
# define RTLD_LOCAL 8
#endif
#endif

static VALUE
library_allocate(VALUE klass)
{
    Library* library;
    return Data_Make_Struct(klass, Library, NULL, library_free, library);
}

static VALUE
library_open(VALUE klass, VALUE libname, VALUE libflags)
{
    return library_initialize(library_allocate(klass), libname, libflags);
}

static VALUE
library_initialize(VALUE self, VALUE libname, VALUE libflags)
{
    Library* library;
    int flags;

    Check_Type(libflags, T_FIXNUM);

    Data_Get_Struct(self, Library, library);
    flags = libflags != Qnil ? NUM2UINT(libflags) : 0;
    
    library->handle = dl_open(libname != Qnil ? StringValueCStr(libname) : NULL, flags);
    if (library->handle == NULL) {
        char errmsg[1024];
        dl_error(errmsg, sizeof(errmsg));
        rb_raise(rb_eLoadError, "Could not open library '%s': %s",
                libname != Qnil ? StringValueCStr(libname) : "[current process]",
                errmsg);
    }
    rb_iv_set(self, "@name", libname != Qnil ? libname : rb_str_new2("[current process]"));
    return self;
}

static VALUE
library_dlsym(VALUE self, VALUE name)
{
    Library* library;
    void* address = NULL;
    Check_Type(name, T_STRING);

    Data_Get_Struct(self, Library, library);
    address = dl_sym(library->handle, StringValueCStr(name));
    
    return address != NULL ? symbol_new(self, address, name) : Qnil;
}

static VALUE
library_dlerror(VALUE self)
{
    char errmsg[1024];
    dl_error(errmsg, sizeof(errmsg));
    return rb_tainted_str_new2(errmsg);
}

static void
library_free(Library* library)
{
    // dlclose() on MacOS tends to segfault - avoid it
#ifndef __APPLE__
    if (library->handle != NULL) {
        dl_close(library->handle);
    }
#endif
    xfree(library);
}

#if defined(_WIN32) || defined(__WIN32__)
static void*
dl_open(const char* name, int flags)
{
    if (name == NULL) {
        return GetModuleHandle(NULL);
    } else {
        return LoadLibraryEx(name, NULL, LOAD_WITH_ALTERED_SEARCH_PATH);
    }
}

static void
dl_error(char* buf, int size)
{
    FormatMessageA(FORMAT_MESSAGE_FROM_SYSTEM, NULL, GetLastError(),
            0, buf, size, NULL);
}
#endif

static VALUE
symbol_allocate(VALUE klass)
{
    LibrarySymbol* sym;
    VALUE obj = Data_Make_Struct(klass, LibrarySymbol, NULL, -1, sym);
    sym->name = Qnil;
    sym->library = Qnil;

    return obj;
}

static VALUE
symbol_new(VALUE library, void* address, VALUE name)
{
    LibrarySymbol* sym;
    VALUE obj = Data_Make_Struct(SymbolClass, LibrarySymbol, symbol_mark, -1, sym);

    sym->memory.address = address;
    sym->memory.size = LONG_MAX;
    sym->memory.typeSize = 1;
    sym->memory.access = MEM_RD | MEM_WR;
    sym->library = library;
    sym->name = name;

    return obj;
}

static void
symbol_mark(LibrarySymbol* sym)
{
    rb_gc_mark(sym->library);
    rb_gc_mark(sym->name);
}

static VALUE
symbol_inspect(VALUE self)
{
    LibrarySymbol* sym;
    char buf[256];

    Data_Get_Struct(self, LibrarySymbol, sym);
    snprintf(buf, sizeof(buf), "#<FFI::Library::Symbol name=%s address=%p>",
             StringValueCStr(sym->name), sym->memory.address);
    return rb_str_new2(buf);
}

void
rbffi_DynamicLibrary_Init(VALUE moduleFFI)
{
    LibraryClass = rb_define_class_under(moduleFFI, "DynamicLibrary", rb_cObject);
    rb_global_variable(&LibraryClass);
    SymbolClass = rb_define_class_under(LibraryClass, "Symbol", rbffi_PointerClass);
    rb_global_variable(&SymbolClass);

    rb_define_const(moduleFFI, "NativeLibrary", LibraryClass); // backwards compat library
    rb_define_alloc_func(LibraryClass, library_allocate);
    rb_define_singleton_method(LibraryClass, "open", library_open, 2);
    rb_define_singleton_method(LibraryClass, "last_error", library_dlerror, 0);
    rb_define_method(LibraryClass, "initialize", library_initialize, 2);
    rb_define_method(LibraryClass, "find_symbol", library_dlsym, 1);
    rb_define_method(LibraryClass, "find_function", library_dlsym, 1);
    rb_define_method(LibraryClass, "find_variable", library_dlsym, 1);
    rb_define_method(LibraryClass, "last_error", library_dlerror, 0);
    rb_define_attr(LibraryClass, "name", 1, 0);

    rb_define_alloc_func(SymbolClass, symbol_allocate);
    rb_undef_method(SymbolClass, "new");
    rb_define_method(SymbolClass, "inspect", symbol_inspect, 0);

#define DEF(x) rb_define_const(LibraryClass, "RTLD_" #x, UINT2NUM(RTLD_##x))
    DEF(LAZY);
    DEF(NOW);
    DEF(GLOBAL);
    DEF(LOCAL);

}

