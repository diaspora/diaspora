/* $OpenBSD: blf.h,v 1.6 2002/02/16 21:27:17 millert Exp $ */
/*
 * Blowfish - a fast block cipher designed by Bruce Schneier
 *
 * Copyright 1997 Niels Provos <provos@physnet.uni-hamburg.de>
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. All advertising materials mentioning features or use of this software
 *    must display the following acknowledgement:
 *      This product includes software developed by Niels Provos.
 * 4. The name of the author may not be used to endorse or promote products
 *    derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#ifndef _BLF_H_
#define _BLF_H_

#include <stdint.h>

// Imported from pwd.h. <coda.hale@gmail.com>
#define	_PASSWORD_LEN		128	/* max length, not counting NUL */

/* Schneier specifies a maximum key length of 56 bytes.
 * This ensures that every key bit affects every cipher
 * bit.  However, the subkeys can hold up to 72 bytes.
 * Warning: For normal blowfish encryption only 56 bytes
 * of the key affect all cipherbits.
 */

#define BLF_N	16			/* Number of Subkeys */
#define BLF_MAXKEYLEN ((BLF_N-2)*4)	/* 448 bits */

/* Blowfish context */
typedef struct BlowfishContext {
	uint32_t S[4][256];	/* S-Boxes */
	uint32_t P[BLF_N + 2];	/* Subkeys */
} blf_ctx;

/* Raw access to customized Blowfish
 *	blf_key is just:
 *	Blowfish_initstate( state )
 *	Blowfish_expand0state( state, key, keylen )
 */

void Blowfish_encipher(blf_ctx *, uint32_t *, uint32_t *);
void Blowfish_decipher(blf_ctx *, uint32_t *, uint32_t *);
void Blowfish_initstate(blf_ctx *);
void Blowfish_expand0state(blf_ctx *, const uint8_t *, uint16_t);
void Blowfish_expandstate
(blf_ctx *, const uint8_t *, uint16_t, const uint8_t *, uint16_t);

/* Standard Blowfish */

void blf_key(blf_ctx *, const uint8_t *, uint16_t);
void blf_enc(blf_ctx *, uint32_t *, uint16_t);
void blf_dec(blf_ctx *, uint32_t *, uint16_t);

void blf_ecb_encrypt(blf_ctx *, uint8_t *, uint32_t);
void blf_ecb_decrypt(blf_ctx *, uint8_t *, uint32_t);

void blf_cbc_encrypt(blf_ctx *, uint8_t *, uint8_t *, uint32_t);
void blf_cbc_decrypt(blf_ctx *, uint8_t *, uint8_t *, uint32_t);

/* Converts uint8_t to uint32_t */
uint32_t Blowfish_stream2word(const uint8_t *, uint16_t , uint16_t *);

#endif
