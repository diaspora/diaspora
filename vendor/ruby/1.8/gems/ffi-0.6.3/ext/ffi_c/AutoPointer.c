
#include <stdbool.h>
#include <stdint.h>
#include <limits.h>
#include <ruby.h>
#include "rbffi.h"
#include "AbstractMemory.h"
#include "Pointer.h"
#include "AutoPointer.h"

typedef struct AutoPointer {
    AbstractMemory memory;
    VALUE parent;
} AutoPointer;

static void autoptr_mark(AutoPointer* ptr);
static VALUE autoptr_allocate(VALUE klass);
static VALUE autoptr_set_parent(VALUE self, VALUE parent);

VALUE rbffi_AutoPointerClass = Qnil;

static VALUE
autoptr_allocate(VALUE klass)
{
    AutoPointer* p;
    VALUE obj = Data_Make_Struct(klass, AutoPointer, autoptr_mark, -1, p);
    p->parent = Qnil;
    p->memory.access = MEM_RD | MEM_WR;

    return obj;
}

static VALUE
autoptr_set_parent(VALUE self, VALUE parent)
{
    AutoPointer* p;
    AbstractMemory* ptr = rbffi_AbstractMemory_Cast(parent, rbffi_PointerClass);

    Data_Get_Struct(self, AutoPointer, p);
    p->memory = *ptr;
    p->parent = parent;

    return self;
}

static void
autoptr_mark(AutoPointer* ptr)
{
    rb_gc_mark(ptr->parent);
}

void
rbffi_AutoPointer_Init(VALUE moduleFFI)
{
    rbffi_AutoPointerClass = rb_define_class_under(moduleFFI, "AutoPointer", rbffi_PointerClass);
    rb_global_variable(&rbffi_AutoPointerClass);
    
    rb_define_alloc_func(rbffi_AutoPointerClass, autoptr_allocate);
    rb_define_protected_method(rbffi_AutoPointerClass, "parent=", autoptr_set_parent, 1);
}
