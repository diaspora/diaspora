module Nokogiri
  module LibXML # :nodoc:
    class XmlAttribute < FFI::Struct # :nodoc:
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

        :nexth,         :pointer,
        :atype,         :int,
        :def,           :int,
        :default_value, :string,
        :tree,          :pointer,
        :prefix,        :string,
        :elem,          :string
        )
    end
  end
end
