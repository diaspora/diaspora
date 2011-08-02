# :stopdoc:
module Nokogiri
  module LibXML
    extend FFI::Library
    if RUBY_PLATFORM =~ /java/ && RbConfig::CONFIG['host_os'] =~ /(mswin|mingw)/i
      raise(RuntimeError, "Nokogiri requires JRuby 1.4.0 or later on Windows") if JRUBY_VERSION < "1.4.0"
      dll_dir = File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "ext", "nokogiri"))
      libs = ["libxml2.dll", "libxslt.dll", "libexslt.dll"].collect do |lib|
        File.join(dll_dir, lib).tr("/","\\") # see http://jira.codehaus.org/browse/JRUBY-2763
      end + ["msvcrt"]
      ffi_lib(*libs)
    else
      ffi_lib 'xml2', 'xslt', 'exslt'
    end

    # globals.c
    attach_function :__xmlParserVersion, [], :pointer
    attach_function :__xmlIndentTreeOutput, [], :pointer
    attach_function :__xmlTreeIndentString, [], :pointer
    attach_function :xmlDeregisterNodeDefault, [:pointer], :pointer
  end

  LIBXML_PARSER_VERSION = LibXML.__xmlParserVersion().read_pointer.read_string
  LIBXML_VERSION = LIBXML_PARSER_VERSION.scan(/^(.*)(..)(..)$/).first.collect{|j|j.to_i}.join(".")

  LIBXML_ICONV_ENABLED = true # sigh.
end

require 'nokogiri/version'

Nokogiri::VERSION_INFO['libxml'] = {}
Nokogiri::VERSION_INFO['libxml']['loaded'] = Nokogiri::LIBXML_VERSION
Nokogiri::VERSION_INFO['libxml']['binding'] = 'ffi'
if RUBY_PLATFORM =~ /java/
  Nokogiri::VERSION_INFO['libxml']['platform'] = 'jruby'
  raise(RuntimeError, "Nokogiri requires JRuby 1.3.0 or later") if JRUBY_VERSION < "1.3.0"
else
  Nokogiri::VERSION_INFO['libxml']['platform'] = 'ruby'
end

module Nokogiri
  module LibXML
    XML_CHAR_ENCODING_ERROR = -1

    # useful callback signatures
    callback :syntax_error_handler, [:pointer, :pointer], :void
    callback :generic_error_handler, [:pointer, :string], :void
    callback :io_write_callback, [:pointer, :string, :int], :int
    callback :io_read_callback, [:pointer, :pointer, :int], :int
    callback :io_close_callback, [:pointer], :int
    callback :hash_copier_callback, [:pointer, :pointer, :string], :void
    callback :xpath_callback, [:pointer, :int], :void
    callback :xpath_lookup_callback, [:pointer, :string, :pointer], :xpath_callback
    callback :start_document_sax_func, [:pointer], :void
    callback :end_document_sax_func, [:pointer], :void
    callback :start_element_sax_func, [:pointer, :string, :pointer], :void
    callback :end_element_sax_func, [:pointer, :string], :void
    callback :characters_sax_func, [:pointer, :string, :int], :void
    callback :comment_sax_func, [:pointer, :string], :void
    callback :warning_sax_func, [:pointer, :string], :void
    callback :error_sax_func, [:pointer, :string], :void
    callback :cdata_block_sax_func, [:pointer, :string, :int], :void
    callback :start_element_ns_sax2_func, [:pointer, :pointer, :pointer, :pointer, :int, :pointer, :int, :int, :pointer], :void
    callback :end_element_ns_sax2_func, [:pointer, :pointer, :pointer, :pointer], :void

    # encoding.c
    attach_function :xmlFindCharEncodingHandler, [:string], :pointer
    attach_function :xmlDelEncodingAlias, [:string], :int
    attach_function :xmlAddEncodingAlias, [:string, :string], :int
    attach_function :xmlCleanupEncodingAliases, [], :void

    # HTMLparser.c
    attach_function :htmlReadMemory, [:string, :int, :string, :string, :int], :pointer
    attach_function :htmlReadIO, [:io_read_callback, :io_close_callback, :pointer, :string, :string, :int], :pointer
    attach_function :htmlNewDoc, [:string, :string], :pointer
    attach_function :htmlTagLookup, [:string], :pointer
    attach_function :htmlEntityLookup, [:string], :pointer
    attach_function :htmlSAXParseFile, [:string, :pointer, :pointer, :pointer], :pointer # second arg 'encoding' should be a string, but we assign it as a pointer elsewhere
    attach_function :htmlSAXParseDoc, [:pointer, :pointer, :pointer, :pointer], :pointer # second arg 'encoding' should be a string, but we assign it as a pointer elsewhere
    attach_function :htmlCreateMemoryParserCtxt, [:pointer, :int], :pointer
    attach_function :htmlCreateFileParserCtxt, [:pointer, :pointer], :pointer
    attach_function :htmlParseDocument, [:pointer], :int
    attach_function :htmlHandleOmittedElem, [:int], :int

    # HTMLtree.c
    attach_function :htmlDocDumpMemory, [:pointer, :pointer, :pointer], :void
    attach_function :htmlNodeDump, [:pointer, :pointer, :pointer], :int
    attach_function :htmlGetMetaEncoding, [:pointer], :string # returns const char*
    attach_function :htmlSetMetaEncoding, [:pointer, :string], :void

    # parser.c
    attach_function :xmlReadMemory, [:string, :int, :string, :string, :int], :pointer
    attach_function :xmlInitParser, [], :void
    attach_function :xmlReadIO, [:io_read_callback, :io_close_callback, :pointer, :string, :string, :int], :pointer
    attach_function :xmlCreateIOParserCtxt, [:pointer, :pointer, :io_read_callback, :io_close_callback, :pointer, :int], :pointer
    attach_function :xmlCreateMemoryParserCtxt, [:pointer, :int], :pointer
    attach_function :xmlCreateFileParserCtxt, [:pointer], :pointer
    attach_function :xmlSAXUserParseMemory, [:pointer, :pointer, :string, :int], :int
    attach_function :xmlSAXUserParseFile, [:pointer, :pointer, :string], :int
    attach_function :xmlParseDocument, [:pointer], :int
    attach_function :xmlFreeParserCtxt, [:pointer], :void
    attach_function :xmlCreatePushParserCtxt, [:pointer, :pointer, :string, :int, :string], :pointer
    attach_function :xmlParseChunk, [:pointer, :string, :int, :int], :int
    attach_function :xmlCtxtUseOptions, [:pointer, :int], :int
    attach_function :xmlParseInNodeContext, [:pointer, :string, :int, :int, :pointer], :pointer

    # tree.c
    attach_function :xmlNewDoc, [:string], :pointer
    attach_function :xmlNewDocFragment, [:pointer], :pointer
    attach_function :xmlDocGetRootElement, [:pointer], :pointer
    attach_function :xmlDocSetRootElement, [:pointer, :pointer], :pointer
    attach_function :xmlCopyDoc, [:pointer, :int], :pointer
    attach_function :xmlFreeDoc, [:pointer], :void
    attach_function :xmlSetTreeDoc, [:pointer, :pointer], :void
    attach_function :xmlNewReference, [:pointer, :string], :pointer
    #    attach_function :xmlFirstElementChild, [:pointer], :pointer
    #    attach_function :xmlLastElementChild, [:pointer], :pointer
    #    attach_function :xmlNextElementSibling, [:pointer], :pointer
    attach_function :xmlNewNode, [:pointer, :string], :pointer
    attach_function :xmlCopyNode, [:pointer, :int], :pointer
    attach_function :xmlDocCopyNode, [:pointer, :pointer, :int], :pointer
    attach_function :xmlReplaceNode, [:pointer, :pointer], :pointer
    attach_function :xmlUnlinkNode, [:pointer], :void
    attach_function :xmlAddChild, [:pointer, :pointer], :pointer
    attach_function :xmlAddNextSibling, [:pointer, :pointer], :pointer
    attach_function :xmlAddPrevSibling, [:pointer, :pointer], :pointer
    attach_function :xmlIsBlankNode, [:pointer], :int
    attach_function :xmlHasProp, [:pointer, :string], :pointer
    attach_function :xmlHasNsProp, [:pointer, :string, :string], :pointer
    attach_function :xmlGetProp, [:pointer, :string], :pointer # returns char* that must be freed
    attach_function :xmlSetProp, [:pointer, :string, :string], :pointer
    attach_function :xmlRemoveProp, [:pointer], :int
    attach_function :xmlNodeSetContent, [:pointer, :string], :void
    attach_function :xmlNodeGetContent, [:pointer], :pointer # returns char* that must be freed
    attach_function :xmlNodeSetName, [:pointer, :string], :void
    attach_function :xmlGetNodePath, [:pointer], :pointer
    attach_function :xmlNewCDataBlock, [:pointer, :string, :int], :pointer
    attach_function :xmlNewDocComment, [:pointer, :string], :pointer
    attach_function :xmlNewDocPI, [:pointer, :string, :string], :pointer
    attach_function :xmlNewText, [:string], :pointer
    attach_function :xmlFreeNode, [:pointer], :void
    attach_function :xmlFreeNodeList, [:pointer], :void
    attach_function :xmlEncodeEntitiesReentrant, [:pointer, :string], :pointer # returns char* that must be freed
    attach_function :xmlStringGetNodeList, [:pointer, :pointer], :pointer # second arg should be a :string, but we only ship the results of xmlEncodeEntitiesReentrant, so let's optimize.
    attach_function :xmlNewNs, [:pointer, :string, :string], :pointer
    attach_function :xmlNewNsProp, [:pointer, :pointer, :string, :string], :pointer
    attach_function :xmlSearchNs, [:pointer, :pointer, :string], :pointer
    attach_function :xmlSearchNsByHref, [:pointer, :pointer, :string], :pointer
    attach_function :xmlGetIntSubset, [:pointer], :pointer
    attach_function :xmlBufferCreate, [], :pointer
    attach_function :xmlBufferFree, [:pointer], :void
    attach_function :xmlSplitQName2, [:string, :buffer_out], :pointer # returns char* that must be freed
    attach_function :xmlNewDocProp, [:pointer, :string, :string], :pointer
    attach_function :xmlFreePropList, [:pointer], :void
    attach_function :xmlCreateIntSubset, [:pointer] * 4, :pointer
    attach_function :xmlNewDtd, [:pointer] * 4, :pointer
    attach_function :xmlGetNsList, [:pointer, :pointer], :pointer
    attach_function :xmlTextMerge, [:pointer, :pointer], :pointer
    attach_function :xmlFreeNsList, [:pointer], :void

    # valid.c
    attach_function :xmlNewValidCtxt, [], :pointer
    attach_function :xmlValidateDtd, [:pointer, :pointer, :pointer], :int
    attach_function :xmlFreeValidCtxt, [:pointer], :void

    # xmlsave.c
    attach_function :xmlDocDumpMemory, [:pointer, :pointer, :pointer], :void
    attach_function :xmlNodeDump, [:pointer, :pointer, :pointer, :int, :int], :int
    attach_function :xmlSaveToIO, [:io_write_callback, :io_close_callback, :pointer, :string, :int], :pointer
    attach_function :xmlSaveTree, [:pointer, :pointer], :int
    attach_function :xmlSaveClose, [:pointer], :int
    attach_function :xmlSetNs, [:pointer, :pointer], :void

    # entities.c
    attach_function :xmlEncodeSpecialChars, [:pointer, :string], :pointer # returns char* that must be freed
    attach_function :xmlAddDocEntity, [:pointer, :string, :int, :string, :string, :string], :pointer

    # xpath.c
    attach_function :xmlXPathInit, [], :void
    attach_function :xmlXPathNewContext, [:pointer], :pointer
    attach_function :xmlXPathFreeContext, [:pointer], :void
    attach_function :xmlXPathEvalExpression, [:string, :pointer], :pointer
    attach_function :xmlXPathRegisterNs, [:pointer, :string, :string], :int
    attach_function :xmlXPathCmpNodes, [:pointer, :pointer], :int
    attach_function :xmlXPathNodeSetContains, [:pointer, :pointer], :int
    attach_function :xmlXPathNodeSetAdd, [:pointer, :pointer], :void
    attach_function :xmlXPathNodeSetAddUnique, [:pointer, :pointer], :void
    attach_function :xmlXPathNodeSetRemove, [:pointer, :int], :void
    attach_function :xmlXPathNodeSetCreate, [:pointer], :pointer
    attach_function :xmlXPathNodeSetDel, [:pointer, :pointer], :void
    attach_function :xmlXPathIntersection, [:pointer, :pointer], :pointer
    attach_function :xmlXPathFreeNodeSetList, [:pointer], :void
    attach_function :xmlXPathRegisterFuncLookup, [:pointer, :xpath_lookup_callback, :pointer], :void
    attach_function :valuePop, [:pointer], :pointer
    attach_function :valuePush, [:pointer, :pointer], :int
    attach_function :xmlXPathCastToString, [:pointer], :pointer # returns char* that must be freed
    attach_function :xmlXPathNodeSetMerge, [:pointer, :pointer], :pointer
    attach_function :xmlXPathWrapNodeSet, [:pointer], :pointer
    attach_function :xmlXPathWrapCString, [:pointer], :pointer # should take a :string, but we optimize
    attach_function :xmlXPathWrapString, [:pointer], :pointer # should take a :string, but we optimize
    attach_function :xmlXPathNewBoolean, [:int], :pointer
    attach_function :xmlXPathNewFloat, [:double], :pointer

    class << self
      # these functions are implemented as C macros
      def xmlXPathReturnNodeSet(ctx, ns)
        valuePush(ctx, xmlXPathWrapNodeSet(ns))
      end
      def xmlXPathReturnTrue(ctx)
        valuePush(ctx, xmlXPathNewBoolean(1))
      end
      def xmlXPathReturnFalse(ctx)
        valuePush(ctx, xmlXPathNewBoolean(0))
      end
      def xmlXPathReturnString(ctx, str)
        valuePush(ctx, xmlXPathWrapString(str))
      end
      def xmlXPathReturnNumber(ctx, val)
        valuePush(ctx, xmlXPathNewFloat(val))
      end
    end

    # xmlstring.c
    attach_function :xmlStrdup, [:string], :pointer # returns char* that must be freed
    def self.xmlFree(pointer)
      # xmlFree is a C preprocessor macro, not an actual function
      self.free(pointer)
    end

    # error.c
    attach_function :xmlSetStructuredErrorFunc, [:pointer, :syntax_error_handler], :void
    attach_function :xmlSetGenericErrorFunc, [:pointer, :generic_error_handler], :void
    attach_function :xmlResetLastError, [], :void
    attach_function :xmlCopyError, [:pointer, :pointer], :int
    attach_function :xmlGetLastError, [], :pointer
    attach_function :xmlCtxtGetLastError, [:pointer], :pointer

    # hash.c
    attach_function :xmlHashScan, [:pointer, :hash_copier_callback, :pointer], :void

    # xmlreader.c
    attach_function :xmlReaderForMemory, [:pointer, :int, :string, :string, :int], :pointer
    attach_function :xmlTextReaderGetAttribute, [:pointer, :string], :pointer # returns char* that must be freed
    attach_function :xmlTextReaderGetAttributeNo, [:pointer, :int], :pointer # returns char* that must be freed
    attach_function :xmlTextReaderLookupNamespace, [:pointer, :string], :pointer # returns char* that must be freed
    attach_function :xmlTextReaderRead, [:pointer], :int
    attach_function :xmlTextReaderReadInnerXml, [:pointer], :pointer
    attach_function :xmlTextReaderReadOuterXml, [:pointer], :pointer
    attach_function :xmlTextReaderAttributeCount, [:pointer], :int
    attach_function :xmlTextReaderCurrentNode, [:pointer], :pointer
    attach_function :xmlTextReaderExpand, [:pointer], :pointer
    attach_function :xmlTextReaderIsDefault, [:pointer], :int
    attach_function :xmlTextReaderDepth, [:pointer], :int
    attach_function :xmlTextReaderConstXmlLang, [:pointer], :pointer # returns a const char*, but must check for null
    attach_function :xmlTextReaderConstLocalName, [:pointer], :pointer # returns a const char* that is deallocated with the reader
    attach_function :xmlTextReaderConstName, [:pointer], :pointer # returns a const char* that is deallocated with the reader
    attach_function :xmlTextReaderConstNamespaceUri, [:pointer], :pointer # returns a const char* that is deallocated with the reader
    attach_function :xmlTextReaderConstPrefix, [:pointer], :pointer # returns a const char* that is deallocated with the reader
    attach_function :xmlTextReaderConstValue, [:pointer], :pointer # returns a const char* that is deallocated on the next read()
    attach_function :xmlTextReaderConstXmlVersion, [:pointer], :pointer # returns a const char* that is deallocated with the reader
    attach_function :xmlTextReaderConstBaseUri, [:pointer], :pointer # returns a const char* that is deallocated with the reader
    attach_function :xmlTextReaderReadState, [:pointer], :int
    attach_function :xmlTextReaderHasValue, [:pointer], :int
    attach_function :xmlFreeTextReader, [:pointer], :void
    attach_function :xmlReaderForIO, [:io_read_callback, :io_close_callback, :pointer, :string, :string, :int], :pointer
    attach_function :xmlTextReaderNodeType, [:pointer], :int
    attach_function :xmlTextReaderIsEmptyElement, [:pointer], :int

    # xslt.c
    attach_function :xsltParseStylesheetDoc, [:pointer], :pointer
    attach_function :xsltFreeStylesheet, [:pointer], :void
    attach_function :xsltApplyStylesheet, [:pointer, :pointer, :pointer], :pointer
    attach_function :xsltSaveResultToString, [:buffer_out, :buffer_out, :pointer, :pointer], :int
    attach_function :xsltSetGenericErrorFunc, [:pointer, :generic_error_handler], :void

    # exslt.c
    attach_function :exsltRegisterAll, [], :void

    # xmlschemas.c
    attach_function :xmlSchemaNewValidCtxt, [:pointer], :pointer
    attach_function :xmlSchemaSetValidStructuredErrors, [:pointer, :syntax_error_handler, :pointer], :void unless Nokogiri.is_2_6_16?
    attach_function :xmlSchemaValidateDoc, [:pointer, :pointer], :void
    attach_function :xmlSchemaFreeValidCtxt, [:pointer], :void
    attach_function :xmlSchemaNewMemParserCtxt, [:pointer, :int], :pointer # first arg could be string, but we pass length, so let's optimize
    attach_function :xmlSchemaSetParserStructuredErrors, [:pointer, :syntax_error_handler, :pointer], :void unless Nokogiri.is_2_6_16?
    attach_function :xmlSchemaParse, [:pointer], :pointer
    attach_function :xmlSchemaFreeParserCtxt, [:pointer], :void
    attach_function :xmlSchemaNewDocParserCtxt, [:pointer], :pointer
    attach_function :xmlSchemaValidateFile, [:pointer, :string, :int], :int

    # relaxng.c
    attach_function :xmlRelaxNGNewValidCtxt, [:pointer], :pointer
    attach_function :xmlRelaxNGSetValidStructuredErrors, [:pointer, :syntax_error_handler, :pointer], :void unless Nokogiri.is_2_6_16?
    attach_function :xmlRelaxNGValidateDoc, [:pointer, :pointer], :int
    attach_function :xmlRelaxNGFreeValidCtxt, [:pointer], :void
    attach_function :xmlRelaxNGNewMemParserCtxt, [:pointer, :int], :pointer # first arg could be string, but we pass length, so let's optimize
    attach_function :xmlRelaxNGSetParserStructuredErrors, [:pointer, :syntax_error_handler, :pointer], :void unless Nokogiri.is_2_6_16?
    attach_function :xmlRelaxNGParse, [:pointer], :pointer
    attach_function :xmlRelaxNGFreeParserCtxt, [:pointer], :void
    attach_function :xmlRelaxNGNewDocParserCtxt, [:pointer], :pointer
    attach_function :xmlRelaxNGFree, [:pointer], :void

    # libc
    attach_function :calloc, [:int, :int], :pointer
    attach_function :free, [:pointer], :void

    attach_function :xmlParseCharEncoding, [:string], :int
    attach_function :xmlSwitchToEncoding, [:pointer, :pointer], :void

    # helpers
    POINTER_SIZE = FFI.type_size(:pointer)
    def self.pointer_offset(n)
      n * POINTER_SIZE # byte offset of nth pointer in an array of pointers
    end

    # ZOMG hacks. see GH#303
    class << self
      def xmlFirstElementChildHack(parent)
        return nil if parent.nil?
        return nil unless [Nokogiri::XML::Node::ELEMENT_NODE, Nokogiri::XML::Node::ENTITY_NODE, Nokogiri::XML::Node::DOCUMENT_NODE, Nokogiri::XML::Node::HTML_DOCUMENT_NODE].include?(parent.type)
        parent.children.find { |child| child.element? }
      end

      def xmlLastElementChildHack(parent)
        return nil if parent.nil?
        return nil unless [Nokogiri::XML::Node::ELEMENT_NODE, Nokogiri::XML::Node::ENTITY_NODE, Nokogiri::XML::Node::DOCUMENT_NODE, Nokogiri::XML::Node::HTML_DOCUMENT_NODE].include?(parent.type)
        parent.children.reverse.find { |child| child.element? }
      end

      def xmlNextElementSiblingHack(sibling)
        return nil if sibling.nil?
        return nil unless [Nokogiri::XML::Node::ELEMENT_NODE, Nokogiri::XML::Node::ENTITY_NODE, Nokogiri::XML::Node::DOCUMENT_NODE, Nokogiri::XML::Node::HTML_DOCUMENT_NODE].include?(sibling.type)
        while (sibling = sibling.next_sibling)
          return sibling if sibling.element?
        end
        nil
      end
    end
  end
end

# :startdoc:

require 'nokogiri/syntax_error'
require 'nokogiri/xml/syntax_error'

[ "io_callbacks",
  "encoding_handler",
  "weak_bucket",
  "structs/common_node",
  "structs/xml_alloc",
  "structs/xml_char_encoding_handler",
  "structs/xml_document",
  "structs/xml_node",
  "structs/xml_dtd",
  "structs/xml_notation",
  "structs/xml_node_set",
  "structs/xml_xpath_context",
  "structs/xml_xpath_object",
  "structs/xml_xpath_parser_context",
  "structs/xml_buffer",
  "structs/xml_syntax_error",
  "structs/xml_attr",
  "structs/xml_ns",
  "structs/xml_schema",
  "structs/xml_relax_ng",
  "structs/xml_text_reader",
  "structs/xml_sax_handler",
  "structs/xml_sax_push_parser_context",
  "structs/xml_enumeration",
  "structs/html_elem_desc",
  "structs/html_entity_desc",
  "structs/xslt_stylesheet",
  "structs/xml_parser_context",
  "structs/xml_attribute",
  "structs/xml_element",
  "structs/xml_entity",
  "structs/xml_element_content",
  "xml/node",
  "xml/namespace",
  "xml/dtd",
  "xml/attr",
  "xml/attribute_decl",
  "xml/element_decl",
  "xml/element_content",
  "xml/entity_decl",
  "xml/document",
  "xml/document_fragment",
  "xml/schema",
  "xml/relax_ng",
  "xml/text",
  "xml/cdata",
  "xml/comment",
  "xml/processing_instruction",
  "xml/node_set",
  "xml/xpath",
  "xml/xpath_context",
  "xml/syntax_error",
  "xml/reader",
  "xml/entity_reference",
  "xml/sax/parser_context",
  "xml/sax/parser",
  "xml/sax/push_parser",
  "html/document",
  "html/element_description",
  "html/entity_lookup",
  "html/sax/parser_context",
  "xslt/stylesheet",
].each do |file|
  require "nokogiri/ffi/#{file}"
end
