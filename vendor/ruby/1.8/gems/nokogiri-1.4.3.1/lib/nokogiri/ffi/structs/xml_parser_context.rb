module Nokogiri
  # :stopdoc:
  module LibXML
    class XmlParserContext < FFI::Struct
      layout(
        :sax,               :pointer,
        :userData,          :pointer,
        :myDoc,             :pointer,
        :wellFormed,        :int,
        :replaceEntities,   :int,
        :version,           :string,
        :encoding,          :string,
        :standalone,        :int,
        :html,              :int
      )
    end
  end
  # :startdoc:
end
