#ifndef JFFI_ENDIAN_H
#define JFFI_ENDIAN_H

#include <sys/param.h>
#include <sys/types.h>

#if defined(__linux__) || defined(__CYGWIN__)
#  include_next <endian.h>
#endif

#ifdef __sun
# include <sys/byteorder.h>
# define LITTLE_ENDIAN 1234
# define BIG_ENDIAN 4321
# if defined(_BIG_ENDIAN)
#  define BYTE_ORDER BIG_ENDIAN
# elif defined(_LITTLE_ENDIAN)
#  define BYTE_ORDER LITTLE_ENDIAN
# else
#  error "Cannot determine endian-ness"
# endif
#endif

#if defined(_AIX) && !defined(BYTE_ORDER)
# define LITTLE_ENDIAN 1234
# define BIG_ENDIAN 4321
# if defined(__BIG_ENDIAN__)
#  define BYTE_ORDER BIG_ENDIAN
# elif defined(__LITTLE_ENDIAN__)
#  define BYTE_ORDER LITTLE_ENDIAN
# else
#  error "Cannot determine endian-ness"
# endif
#endif

#if !defined(BYTE_ORDER) || !defined(LITTLE_ENDIAN) || !defined(BIG_ENDIAN)
#  error "Cannot determine the endian-ness of this platform"
#endif

#endif /* JFFI_ENDIAN_H */

