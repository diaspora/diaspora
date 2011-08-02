module Nokogiri
  module LibXML # :nodoc:
    class HtmlEntityDesc < FFI::Struct # :nodoc:

      layout(
        :value, :int,
        :name,  :char,
        :desc,  :char
        )

    end
  end
end
