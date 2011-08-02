module Nokogiri
  module XML
    class Namespace
      # :stopdoc:

      attr_accessor :cstruct
      attr_accessor :document

      def prefix
        cstruct[:prefix].nil? ? nil : cstruct[:prefix] # TODO: encoding?
      end

      def href
        cstruct[:href].nil? ? nil : cstruct[:href] # TODO: encoding?
      end

      class << self
        def wrap(document, node_struct)
          if node_struct.is_a?(FFI::Pointer)
            # cast native pointers up into a node cstruct
            return nil if node_struct.null?
            node_struct = LibXML::XmlNs.new(node_struct) 
          end

          ruby_node = node_struct.ruby_node
          return ruby_node unless ruby_node.nil?

          ns = Nokogiri::XML::Namespace.allocate
          ns.document = document.ruby_doc
          ns.cstruct = node_struct

          ns.cstruct.ruby_node = ns

          cache = ns.document.instance_variable_get(:@node_cache)
          cache << ns

          ns
        end
      end

      # :startdoc:
    end
  end
end
