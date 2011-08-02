module Nokogiri
  module LibXML # :nodoc:
    class XmlTextReader < FFI::ManagedStruct # :nodoc:

      layout :dummy, :int # to avoid @layout warnings

      def self.release ptr
        LibXML.xmlFreeTextReader(ptr)
      end
    end
  end
end
