# -*- makefile -*-

include ${srcdir}/libffi.gnu.mk

CCACHE := $(shell type -p ccache)
BUILD_DIR := $(shell pwd)

INCFLAGS += -I${BUILD_DIR}

# Work out which arches we need to compile the lib for
ARCHES := 
ifneq ($(findstring -arch ppc,$(CFLAGS)),)
  ARCHES += ppc
endif

ifneq ($(findstring -arch i386,$(CFLAGS)),)
  ARCHES += i386
endif

ifneq ($(findstring -arch x86_64,$(CFLAGS)),)
  ARCHES += x86_64
endif

ifeq ($(strip $(ARCHES)),)
# Just build the one (default) architecture
$(LIBFFI):		
	@mkdir -p $(LIBFFI_BUILD_DIR)
	@if [ ! -f $(LIBFFI_BUILD_DIR)/Makefile ]; then \
	    echo "Configuring libffi"; \
	    cd $(LIBFFI_BUILD_DIR) && \
		/usr/bin/env CC="$(CC)" LD="$(LD)" CFLAGS="$(LIBFFI_CFLAGS)" \
		/bin/sh $(LIBFFI_CONFIGURE) $(LIBFFI_HOST) > /dev/null; \
	fi
	cd $(LIBFFI_BUILD_DIR) && $(MAKE)

else
# Build a fat binary and assemble
build_ffi = \
	mkdir -p $(BUILD_DIR)/libffi-$(1); \
	(if [ ! -f $(BUILD_DIR)/libffi-$(1)/Makefile ]; then \
	    echo "Configuring libffi for $(1)"; \
	    cd $(BUILD_DIR)/libffi-$(1) && \
	      env CC="$(CCACHE) $(CC)" CFLAGS="-arch $(1) $(LIBFFI_CFLAGS)" LDFLAGS="-arch $(1)" \
		$(LIBFFI_CONFIGURE) --host=$(1)-apple-darwin > /dev/null; \
	fi); \
	env MACOSX_DEPLOYMENT_TARGET=10.4 $(MAKE) -C $(BUILD_DIR)/libffi-$(1)

$(LIBFFI):
	@for arch in $(ARCHES); do $(call build_ffi,$$arch);done	
	# Assemble into a FAT (x86_64, i386, ppc) library
	@mkdir -p $(BUILD_DIR)/libffi/.libs
	/usr/bin/libtool -static -o $@ \
	    $(foreach arch, $(ARCHES),$(BUILD_DIR)/libffi-$(arch)/.libs/libffi_convenience.a)
	@mkdir -p $(LIBFFI_BUILD_DIR)/include
	$(RM) $(LIBFFI_BUILD_DIR)/include/ffi.h
	@( \
		printf "#if defined(__i386__)\n"; \
		printf "#include \"libffi-i386/include/ffi.h\"\n"; \
		printf "#elif defined(__x86_64__)\n"; \
		printf "#include \"libffi-x86_64/include/ffi.h\"\n";\
		printf "#elif defined(__ppc__)\n"; \
		printf "#include \"libffi-ppc/include/ffi.h\"\n";\
		printf "#endif\n";\
	) > $(LIBFFI_BUILD_DIR)/include/ffi.h
	@( \
		printf "#if defined(__i386__)\n"; \
		printf "#include \"libffi-i386/include/ffitarget.h\"\n"; \
		printf "#elif defined(__x86_64__)\n"; \
		printf "#include \"libffi-x86_64/include/ffitarget.h\"\n";\
		printf "#elif defined(__ppc__)\n"; \
		printf "#include \"libffi-ppc/include/ffitarget.h\"\n";\
		printf "#endif\n";\
	) > $(LIBFFI_BUILD_DIR)/include/ffitarget.h

endif
