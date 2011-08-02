# :stopdoc:
module Nokogiri
  module XML
    class ElementDecl < Nokogiri::XML::Node
      def element_type
        cstruct[:etype]
      end

      def prefix
        cstruct[:prefix]
      end

      def content
        ElementContent.wrap cstruct[:content], document
      end
    end
  end
end
# :startdoc:
