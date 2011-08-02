module Nokogiri
  module XML
    class ProcessingInstruction < Node

      attr_accessor :cstruct # :nodoc:

      def self.new(document, name, content, *rest) # :nodoc:
        node_ptr = LibXML.xmlNewDocPI(document.cstruct, name.to_s, content.to_s)
        node_cstruct = LibXML::XmlNode.new(node_ptr)
        node_cstruct.keep_reference_from_document!

        node = Node.wrap(node_cstruct, self)
        node.send :initialize, document, name, content, *rest
        yield node if block_given?
        node
      end

    end
  end
end
