
SHELL = /bin/sh

#### Start of system configuration section. ####

srcdir = .
topdir = /usr/lib/ruby/1.8/x86_64-linux
hdrdir = $(topdir)
VPATH = $(srcdir):$(topdir):$(hdrdir)
exec_prefix = $(prefix)
prefix = $(DESTDIR)/usr
sharedstatedir = $(prefix)/com
mandir = $(prefix)/share/man
psdir = $(docdir)
oldincludedir = $(DESTDIR)/usr/include
localedir = $(datarootdir)/locale
bindir = $(exec_prefix)/bin
libexecdir = $(prefix)/lib/ruby1.8
sitedir = $(DESTDIR)/usr/local/lib/site_ruby
htmldir = $(docdir)
vendorarchdir = $(vendorlibdir)/$(sitearch)
includedir = $(prefix)/include
infodir = $(prefix)/share/info
vendorlibdir = $(vendordir)/$(ruby_version)
sysconfdir = $(DESTDIR)/etc
libdir = $(exec_prefix)/lib
sbindir = $(exec_prefix)/sbin
rubylibdir = $(libdir)/ruby/$(ruby_version)
docdir = $(datarootdir)/doc/$(PACKAGE)
dvidir = $(docdir)
vendordir = $(libdir)/ruby/vendor_ruby
datarootdir = $(prefix)/share
pdfdir = $(docdir)
archdir = $(rubylibdir)/$(arch)
sitearchdir = $(sitelibdir)/$(sitearch)
datadir = $(datarootdir)
localstatedir = $(DESTDIR)/var
sitelibdir = $(sitedir)/$(ruby_version)

CC = gcc
LIBRUBY = $(LIBRUBY_SO)
LIBRUBY_A = lib$(RUBY_SO_NAME)-static.a
LIBRUBYARG_SHARED = -l$(RUBY_SO_NAME)
LIBRUBYARG_STATIC = -l$(RUBY_SO_NAME)-static

RUBY_EXTCONF_H = 
CFLAGS   =  -fPIC -fno-strict-aliasing -g -g -O2  -fPIC $(cflags)  -g -DXP_UNIX -O3 -Wall -Wcast-qual -Wwrite-strings -Wconversion -Wmissing-noreturn -Winline 
INCFLAGS = -I. -I. -I/usr/lib/ruby/1.8/x86_64-linux -I.
DEFS     = 
CPPFLAGS = -DHAVE_XMLFIRSTELEMENTCHILD -DHAVE_XMLRELAXNGSETPARSERSTRUCTUREDERRORS -DHAVE_XMLRELAXNGSETPARSERSTRUCTUREDERRORS -DHAVE_XMLRELAXNGSETVALIDSTRUCTUREDERRORS -DHAVE_XMLSCHEMASETVALIDSTRUCTUREDERRORS -DHAVE_XMLSCHEMASETPARSERSTRUCTUREDERRORS -I-I-I/opt/local/include -I-I-I/usr/local/include -I-I-I/usr/include -I-I-I/usr/include -I-I-I/usr/include/libxml2 -I/opt/local/include/libxml2 -I/usr/local/include/libxml2 -I-I/opt/local/include -I-I/usr/local/include -I-I/usr/include -I-I/usr/include -I-I/usr/include/libxml2 -I/opt/local/include -I/usr/local/include -I/usr/include -I/usr/include -I/usr/include/libxml2   
CXXFLAGS = $(CFLAGS) 
ldflags  = -L.  -rdynamic -Wl,-export-dynamic
dldflags = 
archflag = 
DLDFLAGS = $(ldflags) $(dldflags) $(archflag)
LDSHARED = $(CC) -shared
AR = ar
EXEEXT = 

RUBY_INSTALL_NAME = ruby1.8
RUBY_SO_NAME = ruby1.8
arch = x86_64-linux
sitearch = x86_64-linux
ruby_version = 1.8
ruby = /usr/bin/ruby1.8
RUBY = $(ruby)
RM = rm -f
MAKEDIRS = mkdir -p
INSTALL = /usr/bin/install -c
INSTALL_PROG = $(INSTALL) -m 0755
INSTALL_DATA = $(INSTALL) -m 644
COPY = cp

#### End of system configuration section. ####

preload = 

libpath = . $(libdir) /opt/local/lib /usr/local/lib /usr/lib
LIBPATH =  -L. -L$(libdir) -L/opt/local/lib -L/usr/local/lib -L/usr/lib
DEFFILE = 

CLEANFILES = mkmf.log
DISTCLEANFILES = 

extout = 
extout_prefix = 
target_prefix = /nokogiri
LOCAL_LIBS = 
LIBS = $(LIBRUBYARG_SHARED) -lexslt -lxslt -lxml2  -lpthread -lrt -ldl -lcrypt -lm   -lc 
SRCS = xml_attribute_decl.c xml_namespace.c xml_encoding_handler.c xml_relax_ng.c xml_attr.c nokogiri.c xml_sax_push_parser.c xml_reader.c xml_processing_instruction.c html_entity_lookup.c xml_text.c xml_io.c xml_entity_decl.c xml_dtd.c xml_sax_parser_context.c xml_node_set.c xml_element_decl.c xml_schema.c xml_node.c xml_syntax_error.c xml_sax_parser.c xml_cdata.c html_element_description.c xml_element_content.c xml_libxml2_hacks.c xml_document.c html_document.c html_sax_parser_context.c xml_document_fragment.c xslt_stylesheet.c xml_xpath_context.c xml_entity_reference.c xml_comment.c
OBJS = xml_attribute_decl.o xml_namespace.o xml_encoding_handler.o xml_relax_ng.o xml_attr.o nokogiri.o xml_sax_push_parser.o xml_reader.o xml_processing_instruction.o html_entity_lookup.o xml_text.o xml_io.o xml_entity_decl.o xml_dtd.o xml_sax_parser_context.o xml_node_set.o xml_element_decl.o xml_schema.o xml_node.o xml_syntax_error.o xml_sax_parser.o xml_cdata.o html_element_description.o xml_element_content.o xml_libxml2_hacks.o xml_document.o html_document.o html_sax_parser_context.o xml_document_fragment.o xslt_stylesheet.o xml_xpath_context.o xml_entity_reference.o xml_comment.o
TARGET = nokogiri
DLLIB = $(TARGET).so
EXTSTATIC = 
STATIC_LIB = 

BINDIR        = $(bindir)
RUBYCOMMONDIR = $(sitedir)$(target_prefix)
RUBYLIBDIR = /home/lasek/diaspora/vendor/ruby/1.8/gems/nokogiri-1.4.3.1/lib$(target_prefix)
RUBYARCHDIR = /home/lasek/diaspora/vendor/ruby/1.8/gems/nokogiri-1.4.3.1/lib$(target_prefix)

TARGET_SO     = $(DLLIB)
CLEANLIBS     = $(TARGET).so $(TARGET).il? $(TARGET).tds $(TARGET).map
CLEANOBJS     = *.o *.a *.s[ol] *.pdb *.exp *.bak

all:		$(DLLIB)
static:		$(STATIC_LIB)

clean:
		@-$(RM) $(CLEANLIBS) $(CLEANOBJS) $(CLEANFILES)

distclean:	clean
		@-$(RM) Makefile $(RUBY_EXTCONF_H) conftest.* mkmf.log
		@-$(RM) core ruby$(EXEEXT) *~ $(DISTCLEANFILES)

realclean:	distclean
install: install-so install-rb

install-so: $(RUBYARCHDIR)
install-so: $(RUBYARCHDIR)/$(DLLIB)
$(RUBYARCHDIR)/$(DLLIB): $(DLLIB)
	$(INSTALL_PROG) $(DLLIB) $(RUBYARCHDIR)
install-rb: pre-install-rb install-rb-default
install-rb-default: pre-install-rb-default
pre-install-rb: Makefile
pre-install-rb-default: Makefile
$(RUBYARCHDIR):
	$(MAKEDIRS) $@

site-install: site-install-so site-install-rb
site-install-so: install-so
site-install-rb: install-rb

.SUFFIXES: .c .m .cc .cxx .cpp .C .o

.cc.o:
	$(CXX) $(INCFLAGS) $(CPPFLAGS) $(CXXFLAGS) -c $<

.cxx.o:
	$(CXX) $(INCFLAGS) $(CPPFLAGS) $(CXXFLAGS) -c $<

.cpp.o:
	$(CXX) $(INCFLAGS) $(CPPFLAGS) $(CXXFLAGS) -c $<

.C.o:
	$(CXX) $(INCFLAGS) $(CPPFLAGS) $(CXXFLAGS) -c $<

.c.o:
	$(CC) $(INCFLAGS) $(CPPFLAGS) $(CFLAGS) -c $<

$(DLLIB): $(OBJS) Makefile
	@-$(RM) $@
	$(LDSHARED) -o $@ $(OBJS) $(LIBPATH) $(DLDFLAGS) $(LOCAL_LIBS) $(LIBS)



###
html_document.o: html_document.c
html_element_description.o: html_element_description.c
html_entity_lookup.o: html_entity_lookup.c
html_sax_parser_context.o: html_sax_parser_context.c
nokogiri.o: nokogiri.c
xml_attr.o: xml_attr.c
xml_attribute_decl.o: xml_attribute_decl.c
xml_cdata.o: xml_cdata.c
xml_comment.o: xml_comment.c
xml_document.o: xml_document.c
xml_document_fragment.o: xml_document_fragment.c
xml_dtd.o: xml_dtd.c
xml_element_content.o: xml_element_content.c
xml_element_decl.o: xml_element_decl.c
xml_encoding_handler.o: xml_encoding_handler.c
xml_entity_decl.o: xml_entity_decl.c
xml_entity_reference.o: xml_entity_reference.c
xml_io.o: xml_io.c
xml_namespace.o: xml_namespace.c
xml_node.o: xml_node.c
xml_node_set.o: xml_node_set.c
xml_processing_instruction.o: xml_processing_instruction.c
xml_reader.o: xml_reader.c
xml_relax_ng.o: xml_relax_ng.c
xml_sax_parser.o: xml_sax_parser.c
xml_sax_parser_context.o: xml_sax_parser_context.c
xml_sax_push_parser.o: xml_sax_push_parser.c
xml_schema.o: xml_schema.c
xml_syntax_error.o: xml_syntax_error.c
xml_text.o: xml_text.c
xml_xpath_context.o: xml_xpath_context.c
xslt_stylesheet.o: xslt_stylesheet.c
