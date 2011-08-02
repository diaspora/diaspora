# :stopdoc:
module Nokogiri
  module XML
    class ElementContent
      attr_accessor :cstruct

      def self.wrap pointer, document
        return nil if pointer.null?

        c = ElementContent.allocate
        c.cstruct = LibXML::XmlElementContent.new pointer
        c.instance_variable_set :@document, document
        c
      end

      def type
        cstruct[:type]
      end

      def prefix
        cstruct[:prefix]
      end

      def occur
        cstruct[:ocur]
      end

      def name
        cstruct[:name]
      end

      private
      def c1
        self.class.wrap cstruct[:c1], document
      end

      def c2
        self.class.wrap cstruct[:c2], document
      end
    end
  end
end
# :startdoc:
