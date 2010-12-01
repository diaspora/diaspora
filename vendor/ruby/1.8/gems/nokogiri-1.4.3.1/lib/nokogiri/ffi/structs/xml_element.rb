module Nokogiri
  # :stopdoc:
  module LibXML
    class XmlElement < FFI::Struct
      include CommonNode

      layout(
        :_private,      :long,
        :type,          :int,
        :name,          :string,
        :children,      :pointer,
        :last,          :pointer,
        :parent,        :pointer,
        :next,          :pointer,
        :prev,          :pointer,
        :doc,           :pointer,

        :etype,         :int,
        :content,       :pointer,
        :properties,    :pointer,
        :prefix,        :string
      )
    end
  end
  # :startdoc:
end
