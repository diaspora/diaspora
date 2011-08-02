# Handles +attr_*+ statements in modules/classes
class YARD::Handlers::Ruby::AttributeHandler < YARD::Handlers::Ruby::Base
  handles method_call(:attr)
  handles method_call(:attr_reader)
  handles method_call(:attr_writer)
  handles method_call(:attr_accessor)
  namespace_only

  process do
    return if statement.type == :var_ref
    read, write = true, false
    params = statement.parameters(false).dup

    # Change read/write based on attr_reader/writer/accessor
    case statement.method_name(true)
    when :attr
      # In the case of 'attr', the second parameter (if given) isn't a symbol.
      if params.size == 2
        write = true if params.pop == s(:var_ref, s(:kw, "true"))
      end
    when :attr_accessor
      write = true
    when :attr_reader
      # change nothing
    when :attr_writer
      read, write = false, true
    end

    # Add all attributes
    validated_attribute_names(params).each do |name|
      namespace.attributes[scope][name] ||= SymbolHash[:read => nil, :write => nil]

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

  protected

  # Strips out any non-essential arguments from the attr statement.
  #
  # @param [Array<Parser::Ruby::AstNode>] params a list of the parameters
  #   in the attr call.
  # @return [Array<String>] the validated attribute names
  # @raise [Parser::UndocumentableError] if the arguments are not valid.
  def validated_attribute_names(params)
    params.map do |obj|
      case obj.type
      when :symbol_literal
        obj.jump(:ident, :op, :kw, :const).source
      when :string_literal
        obj.jump(:string_content).source
      else
        raise YARD::Parser::UndocumentableError, obj.source
      end
    end
  end
end