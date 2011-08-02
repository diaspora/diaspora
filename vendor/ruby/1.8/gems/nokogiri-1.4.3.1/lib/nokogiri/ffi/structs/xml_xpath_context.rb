module Nokogiri
  module LibXML # :nodoc:
    module XmlXpathContextMixin # :nodoc:
      def self.included(base)
        base.class_eval do

          layout(
            :doc,  :pointer,
            :node, :pointer
            )

        end
      end

      def node
        LibXML::XmlNode.new(self[:node])
      end

      def document
        p = self[:doc]
        p.null? ? nil : LibXML::XmlDocumentCast.new(p)
      end
    end

    class XmlXpathContext < FFI::ManagedStruct # :nodoc:
      include XmlXpathContextMixin

      def self.release ptr
        LibXML.xmlXPathFreeContext(ptr)
      end
    end

    class XmlXpathContextCast < FFI::Struct # :nodoc:
      include XmlXpathContextMixin
    end

  end
end
