module Nokogiri
  module LibXML # :nodoc:
    class XsltStylesheet < FFI::ManagedStruct # :nodoc:

      layout :dummy, :int, 0 # to avoid @layout warnings

      def self.release ptr
        LibXML.xsltFreeStylesheet(ptr)
      end

    end
  end
end
