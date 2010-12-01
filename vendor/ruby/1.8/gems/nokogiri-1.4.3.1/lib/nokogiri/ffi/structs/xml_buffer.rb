module Nokogiri
  module LibXML # :nodoc:
    class XmlBuffer < FFI::ManagedStruct # :nodoc:

      layout(
        :content,       :string,
        :use,           :int,
        :size,          :int
        )

      def self.release ptr
        LibXML.xmlBufferFree(ptr)
      end
    end
  end
end
