#ifndef RBFFI_LASTERROR_H
#define	RBFFI_LASTERROR_H

#ifdef	__cplusplus
extern "C" {
#endif


void rbffi_LastError_Init(VALUE moduleFFI);

void rbffi_save_errno(void);

#ifdef	__cplusplus
}
#endif

#endif	/* RBFFI_LASTERROR_H */

