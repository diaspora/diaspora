module Nokogiri
  module XML
    class Text < CharacterData

      def self.new(string, document, *rest) # :nodoc:
        node_ptr = LibXML.xmlNewText(string)
        node_cstruct = LibXML::XmlNode.new(node_ptr)
        node_cstruct[:doc] = document.cstruct[:doc]

        node = Node.wrap(node_cstruct, self)
        node.send :initialize, string, document, *rest
        yield node if block_given?
        node
      end

    end
  end
end
