module Nokogiri
  module XML
    # :stopdoc:
    class AttributeDecl < Nokogiri::XML::Node
      def enumeration
        list = []
        return list if cstruct[:tree].null?
        head = LibXML::XmlEnumeration.new cstruct[:tree]
        loop do
          list << head[:name]
          break if head[:next].null?
          head = LibXML::XmlEnumeration.new head[:next]
        end
        list
      end

      def attribute_type
        cstruct[:atype]
      end

      def default
        cstruct[:default_value]
      end
    end
    # :startdoc:
  end
end
