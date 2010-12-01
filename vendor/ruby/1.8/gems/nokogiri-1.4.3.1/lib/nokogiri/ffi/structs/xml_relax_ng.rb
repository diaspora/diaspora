module Nokogiri
  module LibXML # :nodoc:
    class XmlRelaxNG < FFI::ManagedStruct # :nodoc:

      layout :dummy, :int, 0 # to avoid @layout warnings

      def self.release ptr
        LibXML.xmlRelaxNGFree(ptr)
      end

    end
  end
end

