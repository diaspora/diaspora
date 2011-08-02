# (see Ruby::AttributeHandler)
class YARD::Handlers::Ruby::Legacy::AttributeHandler < YARD::Handlers::Ruby::Legacy::Base
  handles /\Aattr(?:_(?:reader|writer|accessor))?(?:\s|\()/
  namespace_only

  process do
    begin
      attr_type   = statement.tokens.first.text.to_sym
      symbols     = tokval_list statement.tokens[2..-1], :attr, TkTRUE, TkFALSE
      read, write = true, false
    rescue SyntaxError
      raise YARD::Parser::UndocumentableError, attr_type
    end

    # Change read/write based on attr_reader/writer/accessor
    case attr_type
    when :attr
      # In the case of 'attr', the second parameter (if given) isn't a symbol.
      write = symbols.pop if symbols.size == 2
    when :attr_accessor
      write = true
    when :attr_reader
      # change nothing
    when :attr_writer
      read, write = false, true
    end

    # Add all attributes
    symbols.each do |name|
      namespace.attributes[scope][name] = SymbolHash[:read => nil, :write => nil]

      # Show their methods as well
      {:read => name, :write => "#{name}="}.each do |type, meth|
        if (type == :read ? read : write)
          namespace.attributes[scope][name][type] = MethodObject.new(namespace, meth, scope) do |o|
            if type == :write
              o.parameters = [['value', nil]]
              src = "def #{meth}(value)"
              full_src = "#{src}\n  @#{name} = value\nend"
              doc = "Sets the attribute #{name}\n@param value the value to set the attribute #{name} to."
            else
              src = "def #{meth}"
              full_src = "#{src}\n  @#{name}\nend"
              doc = "Returns the value of attribute #{name}"
            end
            o.source ||= full_src
            o.signature ||= src
            o.docstring = statement.comments.to_s.empty? ? doc : statement.comments
            o.visibility = visibility
          end

          # Register the objects explicitly
          register namespace.attributes[scope][name][type]
        elsif obj = namespace.children.find {|o| o.name == meth.to_sym && o.scope == scope }
          # register an existing method as attribute
          namespace.attributes[scope][name][type] = obj
        end
      end
    end
  end
end