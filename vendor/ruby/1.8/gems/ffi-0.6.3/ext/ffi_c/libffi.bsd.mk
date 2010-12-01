# -*- makefile -*-
#
# Makefile for BSD systems
#

INCFLAGS += -I${LIBFFI_BUILD_DIR}/include
LOCAL_LIBS += ${LIBFFI} -lpthread

LIBFFI_CFLAGS = ${FFI_MMAP_EXEC} -pthread
LIBFFI_BUILD_DIR = ${.CURDIR}/libffi

.if ${srcdir} == "."
  LIBFFI_SRC_DIR := ${.CURDIR}/libffi
.else
  LIBFFI_SRC_DIR := ${srcdir}/libffi
.endif


LIBFFI = ${LIBFFI_BUILD_DIR}/.libs/libffi_convenience.a
LIBFFI_CONFIGURE = ${LIBFFI_SRC_DIR}/configure --disable-static \
	--with-pic=yes --disable-dependency-tracking

$(OBJS):	${LIBFFI}

$(LIBFFI):		
	@mkdir -p ${LIBFFI_BUILD_DIR}
	@if [ ! -f ${LIBFFI_BUILD_DIR}/Makefile ]; then \
	    echo "Configuring libffi"; \
	    cd ${LIBFFI_BUILD_DIR} && \
		/usr/bin/env CC="${CC}" LD="${LD}" CFLAGS="${LIBFFI_CFLAGS}" \
		/bin/sh ${LIBFFI_CONFIGURE} ${LIBFFI_HOST} > /dev/null; \
	fi
	@cd ${LIBFFI_BUILD_DIR} && ${MAKE}

