# :stopdoc:
module Nokogiri
  module XML
    class DTD < Node
      def validate document
        error_list = []
        ctxt = LibXML.xmlNewValidCtxt

        LibXML.xmlSetStructuredErrorFunc(nil, SyntaxError.error_array_pusher(error_list))
        LibXML.xmlValidateDtd ctxt, document.cstruct, cstruct

        LibXML.xmlSetStructuredErrorFunc nil, nil

        LibXML.xmlFreeValidCtxt ctxt

        error_list
      end

      def system_id
        cstruct[:system_id]
      end

      def external_id
        cstruct[:external_id]
      end

      def elements
        internal_attributes :elements
      end

      def entities
        internal_attributes :entities
      end

      def attributes
        internal_attributes :attributes
      end

      def notations
        attr_ptr = cstruct[:notations]
        return nil if attr_ptr.null?

        ahash = {}
        LibXML.xmlHashScan(attr_ptr, nil) do |payload, data, name|
          notation_cstruct = LibXML::XmlNotation.new(payload)
          ahash[name] = Notation.new(notation_cstruct[:name], notation_cstruct[:PublicID],
                                     notation_cstruct[:SystemID])
        end
        ahash
      end

      private

      def internal_attributes attr_name
        attr_ptr = cstruct[attr_name.to_sym]
        return nil if attr_ptr.null?

        ahash = {}
        LibXML.xmlHashScan(attr_ptr, nil) do |payload, data, name|
          ahash[name] = Node.wrap(payload)
        end
        ahash
      end
    end
  end
end
# :startdoc:
