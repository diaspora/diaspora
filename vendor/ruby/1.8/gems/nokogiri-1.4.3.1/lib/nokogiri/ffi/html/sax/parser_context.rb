# :stopdoc:
module Nokogiri
  module HTML
    module SAX
      class ParserContext < Nokogiri::XML::SAX::ParserContext
        attr_accessor :cstruct

        def self.file filename, encoding
          ctx = LibXML.htmlCreateFileParserCtxt filename, encoding
          pc = allocate
          pc.cstruct = LibXML::XmlParserContext.new ctx
          pc
        end

        def self.memory data, encoding
          raise ArgumentError unless data
          raise "data cannot be empty" unless data.length > 0

          ctx = LibXML.htmlCreateMemoryParserCtxt data, data.length
          pc = allocate
          pc.cstruct = LibXML::XmlParserContext.new ctx
          if encoding
            enc = LibXML.xmlFindCharEncodingHandler(encoding)
            if !enc.null?
              LibXML.xmlSwitchToEncoding(ctx, enc)
            end
          end
          pc
        end

        def parse_with sax_handler, type = :html
          super
        end
      end
    end
  end
end
# :startdoc:
