module Nokogiri
  module XML
    class RelaxNG < Schema
      # :stopdoc:
      def validate_document document
        errors = []

        ctx = LibXML.xmlRelaxNGNewValidCtxt(cstruct)
        raise RuntimeError.new("Could not create a validation context") if ctx.null?

        LibXML.xmlRelaxNGSetValidStructuredErrors(ctx,
          SyntaxError.error_array_pusher(errors), nil) unless Nokogiri.is_2_6_16?

        LibXML.xmlRelaxNGValidateDoc(ctx, document.cstruct)

        LibXML.xmlRelaxNGFreeValidCtxt(ctx)

        errors
      end
      private :validate_document

      def self.read_memory content
        content_copy = FFI::MemoryPointer.from_string(content)
        ctx = LibXML.xmlRelaxNGNewMemParserCtxt(content_copy, content.length)

        errors = []

        LibXML.xmlSetStructuredErrorFunc(nil, SyntaxError.error_array_pusher(errors))
        LibXML.xmlRelaxNGSetParserStructuredErrors(
          ctx, SyntaxError.error_array_pusher(errors), nil) unless Nokogiri.is_2_6_16?

        schema_ptr = LibXML.xmlRelaxNGParse(ctx)

        LibXML.xmlSetStructuredErrorFunc(nil, nil)
        LibXML.xmlRelaxNGFreeParserCtxt(ctx)

        if schema_ptr.null?
          error = LibXML.xmlGetLastError
          if error
            raise SyntaxError.wrap(error)
          else
            raise RuntimeError, "Could not parse document"
          end
        end

        schema = allocate
        schema.cstruct = LibXML::XmlRelaxNG.new schema_ptr
        schema.errors = errors
        schema
      end

      def self.from_document document
        ctx = LibXML.xmlRelaxNGNewDocParserCtxt document.document.cstruct

        errors = []

        LibXML.xmlSetStructuredErrorFunc(nil, SyntaxError.error_array_pusher(errors))
        LibXML.xmlRelaxNGSetParserStructuredErrors(
          ctx, SyntaxError.error_array_pusher(errors), nil) unless Nokogiri.is_2_6_16?

        schema_ptr = LibXML.xmlRelaxNGParse(ctx)

        LibXML.xmlSetStructuredErrorFunc(nil, nil)
        LibXML.xmlRelaxNGFreeParserCtxt(ctx) unless Nokogiri.is_2_6_16?

        if schema_ptr.null?
          error = LibXML.xmlGetLastError
          if error
            raise SyntaxError.wrap(error)
          else
            raise RuntimeError, "Could not parse document"
          end
        end

        LibXML.xmlRelaxNGFreeParserCtxt(ctx) if Nokogiri.is_2_6_16?

        schema = allocate
        schema.cstruct = LibXML::XmlRelaxNG.new schema_ptr
        schema.errors = errors
        schema
      end
      # :startdoc:
    end
  end
end
