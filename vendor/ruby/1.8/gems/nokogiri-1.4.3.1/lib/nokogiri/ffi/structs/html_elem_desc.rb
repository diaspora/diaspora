module Nokogiri
  module LibXML # :nodoc:
    class HtmlElemDesc < FFI::Struct # :nodoc:

      layout(
        :name,          :string,
        :startTag,      :char,
        :endTag,        :char,
        :saveEndTag,    :char,
        :empty,         :char,
        :depr,          :char,
        :dtd,           :char,
        :isinline,      :char,
        :desc,          :string,
        :subelts,       :pointer,
        :defaultsubelt, :string,
        :attrs_opt,     :pointer,
        :attrs_depr,    :pointer,
        :attrs_req,     :pointer
        )
        
    end
  end
end
