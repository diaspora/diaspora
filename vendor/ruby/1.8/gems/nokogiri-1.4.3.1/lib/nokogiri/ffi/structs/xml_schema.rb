module Nokogiri
  module LibXML # :nodoc:
    class XmlSchema < FFI::ManagedStruct # :nodoc:

      layout :dummy, :int, 0 # to avoid @layout warnings

      def self.release ptr
        LibXML.xmlSchemaFree(ptr)
      end

    end
  end
end
