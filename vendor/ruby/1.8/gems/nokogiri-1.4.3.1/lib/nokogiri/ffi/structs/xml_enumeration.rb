module Nokogiri
  # :stopdoc:
  module LibXML
    class XmlEnumeration < FFI::Struct
      layout(
        :next, :pointer,
        :name, :string
      )
    end
  end
  # :startdoc:
end
