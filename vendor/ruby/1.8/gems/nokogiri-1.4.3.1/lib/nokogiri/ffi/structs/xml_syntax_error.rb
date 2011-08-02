module Nokogiri
  module LibXML # :nodoc:
    class XmlSyntaxError < FFI::ManagedStruct # :nodoc:

      layout(
        :domain,  :int,
        :code,    :int,
        :message, :pointer,
        :level,   :int,
        :file,    :string,
        :line,    :int,
        :str1,    :string,
        :str2,    :string,
        :str3,    :string,
        :int1,    :int,
        :int2,    :int,
        :ctxt,    :pointer,
        :node,    :pointer
        )

      def self.allocate
        LibXML.calloc(1, LibXML::XmlSyntaxError.size)
      end

      def self.release(ptr)
        LibXML.free(ptr)
      end

    end
  end
end
