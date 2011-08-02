# -*- makefile -*-

include ${srcdir}/libffi.gnu.mk

$(LIBFFI):		
	@mkdir -p $(LIBFFI_BUILD_DIR)
	@if [ ! -f $(LIBFFI_BUILD_DIR)/Makefile ]; then \
	    echo "Configuring libffi"; \
	    cd $(LIBFFI_BUILD_DIR) && \
		/usr/bin/env CFLAGS="$(LIBFFI_CFLAGS)" \
		/bin/sh $(LIBFFI_CONFIGURE) $(LIBFFI_HOST) > /dev/null; \
	fi
	cd $(LIBFFI_BUILD_DIR) && $(MAKE)
