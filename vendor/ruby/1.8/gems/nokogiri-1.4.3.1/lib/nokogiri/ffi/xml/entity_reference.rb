module Nokogiri
  module XML
    class EntityReference < Node

      def self.new(document, name, *rest) # :nodoc:
        node_ptr = LibXML.xmlNewReference(document.cstruct, name)
        node_cstruct = LibXML::XmlNode.new(node_ptr)
        node_cstruct.keep_reference_from_document!

        node = Node.wrap(node_cstruct, self)
        node.send :initialize, document, name, *rest
        yield node if block_given?
        node
      end

    end
  end
end

