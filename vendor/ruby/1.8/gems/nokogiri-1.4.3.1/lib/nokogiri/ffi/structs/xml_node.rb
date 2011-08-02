module Nokogiri
  module LibXML # :nodoc:
    class XmlNode < FFI::Struct # :nodoc:

      layout(
        :_private,      :long, # actually a pointer we're casting as an integer
        :type,          :int,
        :name,          :string,
        :children,      :pointer,
        :last,          :pointer,
        :parent,        :pointer,
        :next,          :pointer,
        :prev,          :pointer,
        :doc,           :pointer,

        :ns,            :pointer,
        :content,       :string,
        :properties,    :pointer,
        :nsDef,         :pointer,
        :psvi,          :pointer,
        :line,          :short
        )

      include CommonNode

    end
  end
end
