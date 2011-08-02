# :stopdoc:
module Nokogiri
  module XML
    module SAX
      class ParserContext
        attr_accessor :cstruct
        attr_accessor :reader_callback

        def self.memory data
          raise(ArgumentError, 'data cannot be nil') if data.nil?
          raise('data cannot be empty') if data.length == 0
          ctx = LibXML::XmlParserContext.new(
            LibXML.xmlCreateMemoryParserCtxt data, data.length
          )
          pc = allocate
          pc.cstruct = ctx
          pc
        end

        def self.io io, encoding
          reader_callback = IoCallbacks.reader(io) # keep a reference to prevent it from being GC'd
          sax_ctx = LibXML.xmlCreateIOParserCtxt(
            nil,
            nil,
            reader_callback,
            nil,
            nil,
            encoding
          )
          pc = allocate
          pc.cstruct = LibXML::XmlParserContext.new sax_ctx
          pc.reader_callback = reader_callback
          pc
        end

        def self.file filename
          ctx = LibXML.xmlCreateFileParserCtxt filename
          pc = allocate
          pc.cstruct = LibXML::XmlParserContext.new ctx
          pc
        end

        def parse_with sax_handler, type = :xml
          raise ArgumentError unless XML::SAX::Parser === sax_handler
          sax = sax_handler.cstruct
          cstruct[:sax] = sax

          sax_handler.instance_variable_set(:@ctxt, cstruct)

          LibXML.send(:"#{type}ParseDocument", cstruct)

          cstruct[:sax] = nil
          LibXML.xmlFreeDoc cstruct[:myDoc] unless cstruct[:myDoc].null?
        end

        def replace_entities=(value)
          self.cstruct[:replaceEntities] = value ? 1 : 0
        end

        def replace_entities
          self.cstruct[:replaceEntities] == 0 ? false : true
        end
      end
    end
  end
end
# :startdoc:
