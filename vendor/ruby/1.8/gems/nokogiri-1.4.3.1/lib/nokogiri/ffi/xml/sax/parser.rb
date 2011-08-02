module Nokogiri
  module XML
    module SAX
      class Parser
        # :stopdoc:

        attr_accessor :cstruct

        def self.new(doc = XML::SAX::Document.new, encoding = 'UTF-8')
          parser = allocate
          parser.document = doc
          parser.encoding = encoding
          parser.cstruct = LibXML::XmlSaxHandler.allocate
          parser.send(:setup_lambdas)
          parser.instance_variable_set(:@ctxt, nil)
          parser
        end

        private

        def setup_lambdas
          @closures = {} # we need to keep references to the closures to avoid GC

          [ :startDocument, :endDocument, :startElement, :endElement, :characters,
            :comment, :warning, :error, :cdataBlock, :startElementNs, :endElementNs ].each do |sym|
            @closures[sym] = lambda { |*args| send("__internal__#{sym}", *args) } # "i'm your private dancer", etc.
          end

          @closures.each { |k,v| cstruct[k] = v }

          cstruct[:initialized] = Nokogiri::LibXML::XmlSaxHandler::XML_SAX2_MAGIC
        end

        def __internal__startDocument(_)
          if @ctxt && @ctxt[:html] == 0 && @ctxt[:standalone] != -1
            standalone = {
              0 => 'no',
              1 => 'yes',
            }[@ctxt[:standalone]]

            @document.xmldecl @ctxt[:version], @ctxt[:encoding], standalone
          end
          @document.start_document
        end

        def __internal__endDocument(_)
          @document.end_document
        end

        def __internal__startElement(_, name, attributes)
          attrs = attributes.null? ? [] : attributes.get_array_of_string(0)
          @document.start_element name, attrs
        end

        def __internal__endElement(_, name)
          @document.end_element name
        end

        def __internal__characters(_, data, data_length)
          @document.characters data.slice(0, data_length)
        end

        def __internal__comment(_, data)
          @document.comment data
        end

        def __internal__warning(_, msg)
          # TODO: vasprintf here
          @document.warning(msg)
        end

        def __internal__error(_, msg)
          # TODO: vasprintf here
          @document.error(msg)
        end

        def __internal__cdataBlock(_, data, data_length)
          @document.cdata_block data.slice(0, data_length)
        end

        def __internal__startElementNs(_, localname, prefix, uri, nb_namespaces, namespaces, nb_attributes, nb_defaulted, attributes)
          localname = localname.null? ? nil : localname.read_string
          prefix    = prefix   .null? ? nil : prefix   .read_string
          uri       = uri      .null? ? nil : uri      .read_string

          attr_list = []
          ns_list   = []

          if ! attributes.null?
            # Each attribute is an array of [localname, prefix, URI, value, end]
            (0..(nb_attributes-1)*5).step(5) do |j|
              key          = attributes.get_pointer(LibXML.pointer_offset(j)).read_string
              attr_prefix = attributes.get_pointer(LibXML.pointer_offset(j + 1))
              attr_prefix = attr_prefix.null? ? nil : attr_prefix.read_string
              attr_uri = attributes.get_pointer(LibXML.pointer_offset(j + 2))
              attr_uri = attr_uri.null? ? nil : attr_uri.read_string
              value_length = attributes.get_pointer(LibXML.pointer_offset(j+4)).address \
                           - attributes.get_pointer(LibXML.pointer_offset(j+3)).address
              value        = attributes.get_pointer(LibXML.pointer_offset(j+3)).get_string(0, value_length)
              attr_list << Attribute.new(key, attr_prefix, attr_uri, value)
            end
          end

          if ! namespaces.null?
            (0..(nb_namespaces-1)*2).step(2) do |j|
              key   = namespaces.get_pointer(LibXML.pointer_offset(j))
              key   = key.null?   ? nil : key.read_string
              value = namespaces.get_pointer(LibXML.pointer_offset(j+1))
              value = value.null? ? nil : value.read_string
              ns_list << [key, value]
            end
          end

          @document.start_element_namespace(
            localname,
            attr_list,
            prefix,
            uri,
            ns_list
          )
        end

        def __internal__endElementNs(_, localname, prefix, uri)
          localname = localname.null? ? nil : localname.read_string
          prefix    = prefix   .null? ? nil : prefix   .read_string
          uri       = uri      .null? ? nil : uri      .read_string

          @document.end_element_namespace(localname, prefix, uri)
        end

        # :startdoc:
      end
    end
  end
end
