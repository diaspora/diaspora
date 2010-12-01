module Nokogiri
  module LibXML # :nodoc:
    #
    #  this class only exists to create a xmlFree() finalizer
    #
    class XmlAlloc < FFI::ManagedStruct # :nodoc:

      layout :dummy, :int, 0 # to avoid @layout warnings

      def self.release ptr
        LibXML.xmlFree(ptr)
      end

    end
  end
end
