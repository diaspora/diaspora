module Nokogiri
  module XML
    class Schema
      # :stopdoc:

      attr_accessor :cstruct

      def validate_document document
        errors = []

        ctx = LibXML.xmlSchemaNewValidCtxt(cstruct)
        raise RuntimeError.new("Could not create a validation context") if ctx.null?

        LibXML.xmlSchemaSetValidStructuredErrors(ctx,
          SyntaxError.error_array_pusher(errors), nil) unless Nokogiri.is_2_6_16?

        LibXML.xmlSchemaValidateDoc(ctx, document.cstruct)

        LibXML.xmlSchemaFreeValidCtxt(ctx)

        errors
      end
      private :validate_document

      def validate_file filename
        errors = []

        ctx = LibXML.xmlSchemaNewValidCtxt(cstruct)
        raise RuntimeError.new("Could not create a validation context") if ctx.null?

        LibXML.xmlSchemaSetValidStructuredErrors(ctx,
          SyntaxError.error_array_pusher(errors), nil) unless Nokogiri.is_2_6_16?

        LibXML.xmlSchemaValidateFile(ctx, filename, 0)

        LibXML.xmlSchemaFreeValidCtxt(ctx)

        errors
      end
      private :validate_document

      def self.read_memory content
        content_copy = FFI::MemoryPointer.from_string(content)
        ctx = LibXML.xmlSchemaNewMemParserCtxt(content_copy, content.length)

        errors = []

        LibXML.xmlSetStructuredErrorFunc(nil, SyntaxError.error_array_pusher(errors))
        LibXML.xmlSchemaSetParserStructuredErrors(ctx, SyntaxError.error_array_pusher(errors), nil) unless Nokogiri.is_2_6_16?

        schema_ptr = LibXML.xmlSchemaParse(ctx)

        LibXML.xmlSetStructuredErrorFunc(nil, nil)
        LibXML.xmlSchemaFreeParserCtxt(ctx)

        if schema_ptr.null?
          error = LibXML.xmlGetLastError
          if error
            raise SyntaxError.wrap(error)
          else
            raise RuntimeError, "Could not parse document"
          end
        end

        schema = allocate
        schema.cstruct = LibXML::XmlSchema.new schema_ptr
        schema.errors = errors
        schema
      end

      def self.from_document document
        ctx = LibXML.xmlSchemaNewDocParserCtxt(document.document.cstruct)

        errors = []

        LibXML.xmlSetStructuredErrorFunc(nil, SyntaxError.error_array_pusher(errors))
        unless Nokogiri.is_2_6_16?
          LibXML.xmlSchemaSetParserStructuredErrors(
            ctx,
            SyntaxError.error_array_pusher(errors),
            nil
          )
        end

        schema_ptr = LibXML.xmlSchemaParse(ctx)

        LibXML.xmlSetStructuredErrorFunc(nil, nil)
        LibXML.xmlSchemaFreeParserCtxt(ctx)

        if schema_ptr.null?
          error = LibXML.xmlGetLastError
          if error
            raise SyntaxError.wrap(error)
          else
            raise RuntimeError, "Could not parse document"
          end
        end

        schema = allocate
        schema.cstruct = LibXML::XmlSchema.new schema_ptr
        schema.errors = errors
        schema
      end

      # :startdoc:
    end
  end
end

