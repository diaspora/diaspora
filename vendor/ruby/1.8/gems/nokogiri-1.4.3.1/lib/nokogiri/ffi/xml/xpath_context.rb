module Nokogiri
  module XML
    class XPathContext

      attr_accessor :cstruct # :nodoc:

      def register_ns(prefix, uri) # :nodoc:
        LibXML.xmlXPathRegisterNs(cstruct, prefix, uri)
      end

      def evaluate(search_path, xpath_handler=nil) # :nodoc:
        lookup = nil # to keep lambda in scope long enough to avoid a possible GC tragedy
        query = search_path.to_s

        if xpath_handler
          lookup = lambda do |ctx, name, uri|
            return nil unless xpath_handler.respond_to?(name)
            ruby_funcall name, xpath_handler
          end
          LibXML.xmlXPathRegisterFuncLookup(cstruct, lookup, nil);
        end

        exception_handler = lambda do |ctx, error|
          raise XPath::SyntaxError.wrap(error)
        end
        LibXML.xmlResetLastError()
        LibXML.xmlSetStructuredErrorFunc(nil, exception_handler)

        generic_exception_handler = lambda do |ctx, msg|
          raise RuntimeError.new(msg) # TODO: varargs
        end
        LibXML.xmlSetGenericErrorFunc(nil, generic_exception_handler)

        xpath_ptr = LibXML.xmlXPathEvalExpression(query, cstruct)

        LibXML.xmlSetStructuredErrorFunc(nil, nil)
        LibXML.xmlSetGenericErrorFunc(nil, nil)

        if xpath_ptr.null?
          error = LibXML.xmlGetLastError()
          raise XPath::SyntaxError.wrap(error)
        end

        xpath = XML::XPath.new
        xpath.cstruct = LibXML::XmlXpathObject.new(xpath_ptr)
        xpath.document = cstruct.document.ruby_doc

        case xpath.cstruct[:type]
        when LibXML::XmlXpathObject::XPATH_NODESET
          if xpath.cstruct[:nodesetval].null?
            NodeSet.new(xpath.document)
          else
            NodeSet.wrap(xpath.cstruct[:nodesetval], xpath.document)
          end
        when LibXML::XmlXpathObject::XPATH_STRING
          xpath.cstruct[:stringval]
        when LibXML::XmlXpathObject::XPATH_NUMBER
          xpath.cstruct[:floatval]
        when LibXML::XmlXpathObject::XPATH_BOOLEAN
          0 != xpath.cstruct[:boolval]
        else
          NodeSet.new(xpath.document)
        end
      end

      def self.new(node) # :nodoc:
        LibXML.xmlXPathInit()

        ptr = LibXML.xmlXPathNewContext(node.cstruct[:doc])

        ctx = allocate
        ctx.cstruct = LibXML::XmlXpathContext.new(ptr)
        ctx.cstruct[:node] = node.cstruct
        ctx
      end

      private

      #
      #  returns a lambda that will call the handler function with marshalled parameters
      #
      def ruby_funcall(name, xpath_handler) # :nodoc:
        lambda do |ctx, nargs|
          parser_context = LibXML::XmlXpathParserContext.new(ctx)
          context_cstruct = parser_context.context
          document = context_cstruct.document.ruby_doc

          params = []

          nargs.times do |j|
            obj = LibXML::XmlXpathObject.new(LibXML.valuePop(ctx))
            case obj[:type]
            when LibXML::XmlXpathObject::XPATH_STRING
              params.unshift obj[:stringval]
            when LibXML::XmlXpathObject::XPATH_BOOLEAN
              params.unshift obj[:boolval] == 1
            when LibXML::XmlXpathObject::XPATH_NUMBER
              params.unshift obj[:floatval]
            when LibXML::XmlXpathObject::XPATH_NODESET
              params.unshift NodeSet.wrap(obj[:nodesetval], document)
            else
              char_ptr = params.unshift LibXML.xmlXPathCastToString(obj)
              string = char_ptr.read_string
              LibXML.xmlFree(char_ptr)
              string
            end
          end

          result = xpath_handler.send(name, *params)

          case result.class.to_s
          when Fixnum.to_s, Float.to_s, Bignum.to_s
            LibXML.xmlXPathReturnNumber(ctx, result)
          when String.to_s
            LibXML.xmlXPathReturnString(
              ctx,
              LibXML.xmlXPathWrapCString(result)
              )
          when TrueClass.to_s
            LibXML.xmlXPathReturnTrue(ctx)
          when FalseClass.to_s
            LibXML.xmlXPathReturnFalse(ctx)
          when NilClass.to_s
            ;
          when Array.to_s
            node_set = XML::NodeSet.new(document, result)
            LibXML.xmlXPathReturnNodeSet(
              ctx,
              LibXML.xmlXPathNodeSetMerge(nil, node_set.cstruct)
              )
          else
            if result.is_a?(XML::NodeSet)
              LibXML.xmlXPathReturnNodeSet(
                ctx,
                LibXML.xmlXPathNodeSetMerge(nil, result.cstruct)
                )
            else
              raise RuntimeError.new("Invalid return type #{result.class.inspect}")
            end
          end

          nil
        end # lambda
      end # ruby_funcall

    end
  end
end
