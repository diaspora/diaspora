module Nokogiri
  module LibXML # :nodoc:

    class XmlXpathParserContext < FFI::Struct # :nodoc:

      layout(
        :cur,     :pointer,
        :base,    :pointer,
        :error,   :int,
        :context, :pointer
        )

      def context
        p = self[:context]
        LibXML::XmlXpathContextCast.new(p)
      end
    end

  end
end
