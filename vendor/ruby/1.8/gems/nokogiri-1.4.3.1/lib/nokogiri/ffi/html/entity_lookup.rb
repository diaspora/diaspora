module Nokogiri
  module HTML
    class EntityLookup

      def get(key) # :nodoc:
        ptr = LibXML.htmlEntityLookup(key.to_s)
        return nil if ptr.null?

        cstruct = LibXML::HtmlEntityDesc.new(ptr)
        EntityDescription.new cstruct[:value], cstruct[:name], cstruct[:desc]
      end

    end
  end
end

