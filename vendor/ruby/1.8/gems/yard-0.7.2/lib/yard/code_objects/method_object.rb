module YARD::CodeObjects
  # Represents a Ruby method in source
  class MethodObject < Base
    # The scope of the method (+:class+ or +:instance+)
    #
    # @return [Symbol] the scope
    attr_reader :scope

    # Whether the object is explicitly defined in source or whether it was
    # inferred by a handler. For instance, attribute methods are generally
    # inferred and therefore not explicitly defined in source.
    #
    # @return [Boolean] whether the object is explicitly defined in source.
    attr_accessor :explicit

    # Returns the list of parameters parsed out of the method signature
    # with their default values.
    #
    # @return [Array<Array(String, String)>] a list of parameter names followed
    #   by their default values (or nil)
    attr_accessor :parameters

    # Creates a new method object in +namespace+ with +name+ and an instance
    # or class +scope+
    #
    # @param [NamespaceObject] namespace the namespace
    # @param [String, Symbol] name the method name
    # @param [Symbol] scope +:instance+ or +:class+
    def initialize(namespace, name, scope = :instance)
      @scope = nil
      self.visibility = :public
      self.scope = scope
      self.parameters = []

      super
    end

    # Changes the scope of an object from :instance or :class
    # @param [Symbol] v the new scope
    def scope=(v)
      reregister = @scope ? true : false
      YARD::Registry.delete(self) if reregister
      @path = nil
      @scope = v.to_sym
      YARD::Registry.register(self) if reregister
    end

    # @return whether or not the method is the #initialize constructor method
    def constructor?
      name == :initialize && scope == :instance && namespace.is_a?(ClassObject)
    end

    # Returns the read/writer info for the attribute if it is one
    # @return [SymbolHash] if there is information about the attribute
    # @return [nil] if the method is not an attribute
    # @since 0.5.3
    def attr_info
      return nil unless namespace.is_a?(NamespaceObject)
      namespace.attributes[scope][name.to_s.gsub(/=$/, '')]
    end

    # @return [Boolean] whether the method is a writer attribute
    # @since 0.5.3
    def writer?
      !!((info = attr_info) && info[:write] == self)
    end

    # @return [Boolean] whether the method is a reader attribute
    # @since 0.5.3
    def reader?
      !!((info = attr_info) && info[:read] == self)
    end

    # Tests if the object is defined as an attribute in the namespace
    # @return [Boolean] whether the object is an attribute
    def is_attribute?
      return false unless info = attr_info
      info[name.to_s =~ /=$/ ? :write : :read] ? true : false
    end

    # Tests if the object is defined as an alias of another method
    # @return [Boolean] whether the object is an alias
    def is_alias?
      return false unless namespace.is_a?(NamespaceObject)
      namespace.aliases.has_key? self
    end

    # Tests boolean {#explicit} value.
    #
    # @return [Boolean] whether the method is explicitly defined in source
    def is_explicit?
      explicit ? true : false
    end

    # @return [MethodObject] the object that this method overrides
    # @return [nil] if it does not override a method
    # @since 0.6.0
    def overridden_method
      return nil if namespace.is_a?(Proxy)
      meths = namespace.meths(:all => true)
      meths.find {|m| m.path != path && m.name == name && m.scope == scope }
    end

    # Returns all alias names of the object
    # @return [Array<Symbol>] the alias names
    def aliases
      list = []
      return list unless namespace.is_a?(NamespaceObject)
      namespace.aliases.each do |o, aname|
        list << o if aname == name && o.scope == scope
      end
      list
    end

    # Override path handling for instance methods in the root namespace
    # (they should still have a separator as a prefix).
    # @return [String] the path of a method
    def path
      @path ||= if !namespace || namespace.path == ""
        sep + super
      else
        super
      end
    end

    # Returns the name of the object.
    #
    # @example The name of an instance method (with prefix)
    #   an_instance_method.name(true) # => "#mymethod"
    # @example The name of a class method (with prefix)
    #   a_class_method.name(true) # => "mymethod"
    # @param [Boolean] prefix whether or not to show the prefix
    # @return [String] returns {#sep} + +name+ for an instance method if
    #   prefix is true
    # @return [Symbol] the name without {#sep} if prefix is set to false
    def name(prefix = false)
      prefix ? (sep == ISEP ? "#{sep}#{super}" : super.to_s) : super
    end

    protected

    # Override separator to differentiate between class and instance
    # methods.
    # @return [String] "#" for an instance method, "." for class
    def sep
      if scope == :class
        namespace && namespace != YARD::Registry.root ? CSEP : NSEP
      else
        ISEP
      end
    end
  end
end
