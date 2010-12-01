module Nokogiri
  module LibXML # :nodoc:
    class XmlNotation < FFI::Struct # :nodoc:
      layout(
        :name,          :string,
        :PublicID,      :string,
        :SystemID,      :string
        )
    end
  end
end
