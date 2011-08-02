module Nokogiri
  module LibXML # :nodoc:
    class XmlAttr < FFI::Struct # :nodoc:

      layout(
        :_private,      :pointer,
        :type,          :int,
        :name,          :string,
        :children,      :pointer,
        :last,          :pointer,
        :parent,        :pointer,
        :next,          :pointer,
        :prev,          :pointer,
        :doc,           :pointer
        )

    end
  end
end
