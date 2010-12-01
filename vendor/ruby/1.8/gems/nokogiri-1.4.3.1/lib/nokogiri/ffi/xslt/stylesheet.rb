module Nokogiri
  module XSLT
    class Stylesheet

      attr_accessor :cstruct # :nodoc:

      def self.parse_stylesheet_doc(document) # :nodoc:
        LibXML.exsltRegisterAll

        generic_exception_handler = lambda do |ctx, msg|
          raise RuntimeError.new(msg) # TODO: varargs
        end
        LibXML.xsltSetGenericErrorFunc(nil, generic_exception_handler)

        ss = LibXML.xsltParseStylesheetDoc(LibXML.xmlCopyDoc(document.cstruct, 1)) # 1 => recursive

        LibXML.xsltSetGenericErrorFunc(nil, nil)

        obj = allocate
        obj.cstruct = LibXML::XsltStylesheet.new(ss)
        obj
      end

      def serialize(document) # :nodoc:
        buf_ptr = FFI::Buffer.new :pointer
        buf_len = FFI::Buffer.new :int
        LibXML.xsltSaveResultToString(buf_ptr, buf_len, document.cstruct, cstruct)
        buf = Nokogiri::LibXML::XmlAlloc.new(buf_ptr.get_pointer(0))
        buf.pointer.read_string(buf_len.get_int(0))
      end

      def transform(document, params=[]) # :nodoc:
        params = params.to_a.flatten if params.is_a?(Hash)
        raise(TypeError) unless params.is_a?(Array)

        param_arr = FFI::MemoryPointer.new(:pointer, params.length + 1, false)

        # Keep the MemoryPointer instances alive until after the call
        ptrs = params.map { |param | FFI::MemoryPointer.from_string(param.to_s) }
        param_arr.put_array_of_pointer(0, ptrs)
        
        # Terminate the list with a NULL pointer
        param_arr.put_pointer(LibXML.pointer_offset(params.length), nil)

        ptr = LibXML.xsltApplyStylesheet(cstruct, document.cstruct, param_arr)
        raise(RuntimeError, "could not perform xslt transform on document") if ptr.null?

        XML::Document.wrap(ptr)
      end

    end
  end
end
