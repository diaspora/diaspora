# :stopdoc:
module Nokogiri
  module XML
    class EntityDecl < Nokogiri::XML::Node

      # from libxml/entities.h
      INTERNAL_GENERAL          = 1
      EXTERNAL_GENERAL_PARSED   = 2
      EXTERNAL_GENERAL_UNPARSED = 3
      INTERNAL_PARAMETER        = 4
      EXTERNAL_PARAMETER        = 5
      INTERNAL_PREDEFINED       = 6

      def content
        cstruct[:content]
      end

      def entity_type
        cstruct[:etype]
      end

      def external_id
        cstruct[:external_id]
      end

      def system_id
        cstruct[:system_id]
      end

      def original_content
        cstruct[:orig]
      end
    end
  end
end
# :startdoc:
