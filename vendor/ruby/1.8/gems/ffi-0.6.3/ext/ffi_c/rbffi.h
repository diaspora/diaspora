#ifndef _RBFFI_H
#define	_RBFFI_H

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
extern VALUE rbffi_AbstractMemoryClass, rbffi_InvokerClass;
extern int rbffi_type_size(VALUE type);

#ifdef	__cplusplus
}
#endif

#endif	/* _RBFFI_H */

