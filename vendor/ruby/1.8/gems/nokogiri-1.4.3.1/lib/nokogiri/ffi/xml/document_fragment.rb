module Nokogiri
  module XML
    class DocumentFragment < Node

      def self.new(document, *rest) # :nodoc:
        node_ptr = LibXML.xmlNewDocFragment(document.cstruct)
        node_cstruct = LibXML::XmlNode.new(node_ptr)
        node_cstruct.keep_reference_from_document!

        node = Node.wrap(node_cstruct, self)

        node.send :initialize, document, *rest
        yield node if block_given?

        node
      end

    end
  end
end

