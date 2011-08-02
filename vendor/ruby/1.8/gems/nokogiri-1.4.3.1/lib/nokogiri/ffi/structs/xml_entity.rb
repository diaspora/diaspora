module Nokogiri
  # :stopdoc:
  module LibXML
    class XmlEntity < FFI::Struct
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

        :orig,          :string,
        :content,       :string,
        :length,        :int,
        :etype,         :int,
        :external_id,   :string,
        :system_id,     :string,
        :nexte,         :pointer,
        :uri,           :string,
        :owner,         :int,
        :checked,       :int
      )
    end
  end
  # :startdoc:
end
