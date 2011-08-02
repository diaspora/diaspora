module Nokogiri
  class EncodingHandler
    # :stopdoc:
    attr_accessor :cstruct

    class << self
      def [](key)
        handler = LibXML.xmlFindCharEncodingHandler(key)
        handler.null? ? nil : wrap(handler)
      end

      def delete(name)
        (LibXML.xmlDelEncodingAlias(name) != 0) ? nil : true
      end

      def alias(from, to)
        LibXML.xmlAddEncodingAlias(from, to)
        to
      end

      def clear_aliases!
        LibXML.xmlCleanupEncodingAliases
        self
      end

      private

      def wrap(ptr)
        cstruct = LibXML::XmlCharEncodingHandler.new(ptr)
        eh = Nokogiri::EncodingHandler.allocate
        eh.cstruct = cstruct
        eh
      end

    end

    def name
      cstruct[:name]
    end
    # :startdoc:
  end
end
