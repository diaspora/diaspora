module Nokogiri
  module LibXML # :nodoc:
    class XmlNs < FFI::Struct # :nodoc:
      layout(
        :next,     :pointer,
        :type,     :int,
        :href,     :string,
        :prefix,   :string,
        :_private, :long # actually a pointer we're casting as an integer
        )

      include CommonNode
    end
  end
end
