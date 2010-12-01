module Nokogiri
  module XML
    class CDATA < Text
      
      def self.new(document, content, *rest) # :nodoc:
        length = content.nil? ? 0 : content.length
        node_ptr = LibXML.xmlNewCDataBlock(document.cstruct[:doc], content, length)
        node_cstruct = LibXML::XmlNode.new(node_ptr)
        node_cstruct.keep_reference_from_document!

        node = Node.wrap(node_cstruct, self)
        node.send :initialize, document, content, *rest
        yield node if block_given?
        node
      end

    end
  end
end
