# :stopdoc:
module Nokogiri
  module XML
    class Reader

      attr_accessor :cstruct
      attr_accessor :reader_callback

      def default?
        LibXML.xmlTextReaderIsDefault(cstruct) == 1
      end

      def value?
        LibXML.xmlTextReaderHasValue(cstruct) == 1
      end

      def attributes?
        #  this implementation of xmlTextReaderHasAttributes explicitly includes
        #  namespaces and properties, because some earlier versions ignore
        #  namespaces.
        node_ptr = LibXML.xmlTextReaderCurrentNode(cstruct)
        return false if node_ptr.null?
        node = LibXML::XmlNode.new node_ptr
        node[:type] == Node::ELEMENT_NODE && (!node[:properties].null? || !node[:nsDef].null?)
      end

      def namespaces
        return {} unless attributes?

        ptr = LibXML.xmlTextReaderExpand(cstruct)
        return nil if ptr.null?

        Reader.node_namespaces(ptr)
      end

      def attr_nodes
        return {} unless attributes?

        ptr = LibXML.xmlTextReaderExpand(cstruct)
        return nil if ptr.null?
        node_struct = LibXML::XmlNode.new(ptr)

        Node.node_properties node_struct
      end

      def attribute_at(index)
        return nil if index.nil?
        index = index.to_i
        attr_ptr = LibXML.xmlTextReaderGetAttributeNo(cstruct, index)
        return nil if attr_ptr.null?

        attr = attr_ptr.read_string
        LibXML.xmlFree attr_ptr
        attr
      end

      def attribute(name)
        return nil if name.nil?
        attr_ptr = LibXML.xmlTextReaderGetAttribute(cstruct, name.to_s)
        if attr_ptr.null?
          # this section is an attempt to workaround older versions of libxml that
          # don't handle namespaces properly in all attribute-and-friends functions
          prefix_ptr = FFI::Buffer.new :pointer
          localname = LibXML.xmlSplitQName2(name, prefix_ptr)
          prefix = prefix_ptr.get_pointer(0)
          if ! localname.null?
            attr_ptr = LibXML.xmlTextReaderLookupNamespace(cstruct, localname.read_string)
            LibXML.xmlFree(localname)
          else
            if prefix.null? || prefix.read_string.length == 0
              attr_ptr = LibXML.xmlTextReaderLookupNamespace(cstruct, nil)
            else
              attr_ptr = LibXML.xmlTextReaderLookupNamespace(cstruct, prefix.read_string)
            end
          end
          LibXML.xmlFree(prefix)
        end
        return nil if attr_ptr.null?

        attr = attr_ptr.read_string
        LibXML.xmlFree(attr_ptr)
        attr
      end

      def attribute_count
        count = LibXML.xmlTextReaderAttributeCount(cstruct)
        count == -1 ? nil : count
      end

      def depth
        val = LibXML.xmlTextReaderDepth(cstruct)
        val == -1 ? nil : val
      end

      def xml_version
        val = LibXML.xmlTextReaderConstXmlVersion(cstruct)
        val.null? ? nil : val.read_string
      end

      def lang
        val = LibXML.xmlTextReaderConstXmlLang(cstruct)
        val.null? ? nil : val.read_string
      end

      def value
        val = LibXML.xmlTextReaderConstValue(cstruct)
        val.null? ? nil : val.read_string
      end

      def prefix
        val = LibXML.xmlTextReaderConstPrefix(cstruct)
        val.null? ? nil : val.read_string
      end

      def namespace_uri
        val = LibXML.xmlTextReaderConstNamespaceUri(cstruct)
        val.null? ? nil : val.read_string
      end

      def local_name
        val = LibXML.xmlTextReaderConstLocalName(cstruct)
        val.null? ? nil : val.read_string
      end

      def name
        val = LibXML.xmlTextReaderConstName(cstruct)
        val.null? ? nil : val.read_string
      end

      def base_uri
        val = LibXML.xmlTextReaderConstBaseUri(cstruct)
        val.null? ? nil : val.read_string
      end

      def state
        LibXML.xmlTextReaderReadState(cstruct)
      end

      def read
        error_list = self.errors

        LibXML.xmlSetStructuredErrorFunc(nil, SyntaxError.error_array_pusher(error_list))
        ret = LibXML.xmlTextReaderRead(cstruct)
        LibXML.xmlSetStructuredErrorFunc(nil, nil)

        return self if ret == 1
        return nil if ret == 0

        error = LibXML.xmlGetLastError()
        if error
          raise SyntaxError.wrap(error)
        else
          raise RuntimeError, "Error pulling: #{ret}"
        end

        nil
      end

      def inner_xml
        string_ptr = LibXML.xmlTextReaderReadInnerXml(cstruct)
        return nil if string_ptr.null?
        string = string_ptr.read_string
        LibXML.xmlFree(string_ptr)
        string
      end

      def outer_xml
        string_ptr = LibXML.xmlTextReaderReadOuterXml(cstruct)
        return nil if string_ptr.null?
        string = string_ptr.read_string
        LibXML.xmlFree(string_ptr)
        string
      end

      def node_type
        LibXML.xmlTextReaderNodeType(cstruct)
      end

      def empty_element?
        LibXML.xmlTextReaderIsEmptyElement(cstruct) != 0
      end

      def self.from_memory(buffer, url=nil, encoding=nil, options=0)
        raise(ArgumentError, "string cannot be nil") if buffer.nil?

        memory = FFI::MemoryPointer.new(buffer.length) # we need to manage native memory lifecycle
        memory.put_bytes(0, buffer)
        reader_ptr = LibXML.xmlReaderForMemory(memory, memory.total, url, encoding, options)
        raise(RuntimeError, "couldn't create a reader") if reader_ptr.null?

        reader = allocate
        reader.cstruct = LibXML::XmlTextReader.new(reader_ptr)
        reader.send(:initialize, memory, url, encoding)
        reader
      end

      def self.from_io(io, url=nil, encoding=nil, options=0)
        raise(ArgumentError, "io cannot be nil") if io.nil?

        cb = IoCallbacks.reader(io) # we will keep a reference to prevent it from being GC'd
        reader_ptr = LibXML.xmlReaderForIO(cb, nil, nil, url, encoding, options)
        raise "couldn't create a parser" if reader_ptr.null?

        reader = allocate
        reader.cstruct = LibXML::XmlTextReader.new(reader_ptr)
        reader.send(:initialize, io, url, encoding)
        reader.reader_callback = cb
        reader
      end

      private

      class << self
        def node_namespaces(ptr)
          cstruct = LibXML::XmlNode.new(ptr)
          ahash = {}
          return ahash unless cstruct[:type] == Node::ELEMENT_NODE
          ns = cstruct[:nsDef]
          while ! ns.null?
            ns_cstruct = LibXML::XmlNs.new(ns)
            prefix = ns_cstruct[:prefix]
            key = if prefix.nil? || prefix.empty?
                    "xmlns"
                  else
                    "xmlns:#{prefix}"
                  end
            ahash[key] = ns_cstruct[:href] # TODO: encoding?
            ns = ns_cstruct[:next] # TODO: encoding?
          end
          ahash
        end
      end
    end
  end
end
# :startdoc:
