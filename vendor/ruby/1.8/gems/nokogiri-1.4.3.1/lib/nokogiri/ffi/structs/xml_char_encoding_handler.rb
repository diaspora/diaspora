module Nokogiri
  module LibXML # :nodoc:
    class XmlCharEncodingHandler < FFI::Struct # :nodoc:
      layout(
        :name,          :string,
        :input,         :pointer,
        :output,        :pointer
        )
    end
  end
end
