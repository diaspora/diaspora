module Nokogiri
  module XML
    class Comment < CharacterData

      def self.new(document, content, *rest) # :nodoc:
        node_ptr = LibXML.xmlNewDocComment(document.cstruct, content)
        node_cstruct = LibXML::XmlNode.new(node_ptr)
        node_cstruct.keep_reference_from_document!

        node = Node.wrap(node_ptr, self)
        node.send :initialize, document, content, *rest
        yield node if block_given?
        node
      end

    end
  end
end
