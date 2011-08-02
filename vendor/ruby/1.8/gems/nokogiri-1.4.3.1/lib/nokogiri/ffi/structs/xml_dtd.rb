module Nokogiri
  module LibXML # :nodoc:
    class XmlDtd < FFI::Struct # :nodoc:

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

        :notations,     :pointer,
        :elements,      :pointer,
        :attributes,    :pointer,
        :entities,      :pointer,
        :external_id,   :string,
        :system_id,     :string
        )

      include CommonNode

    end
  end
end
