module YARD
  module CodeObjects
    # A list of code objects. This array acts like a set (no unique items)
    # but also disallows any {Proxy} objects from being added.
    class CodeObjectList < Array
      # Creates a new object list associated with a namespace
      #
      # @param [NamespaceObject] owner the namespace the list should be associated with
      # @return [CodeObjectList]
      def initialize(owner = Registry.root)
        @owner = owner
      end

      # Adds a new value to the list
      #
      # @param [Base] value a code object to add
      # @return [CodeObjectList] self
      def push(value)
        value = Proxy.new(@owner, value) if value.is_a?(String) || value.is_a?(Symbol)
        if value.is_a?(CodeObjects::Base) || value.is_a?(Proxy)
          super(value) unless include?(value)
        else
          raise ArgumentError, "#{value.class} is not a valid CodeObject"
        end
        self
      end
      alias_method :<<, :push
    end


    # Namespace separator
    NSEP = '::'

    # Regex-quoted namespace separator
    NSEPQ = NSEP

    # Instance method separator
    ISEP = '#'

    # Regex-quoted instance method separator
    ISEPQ = ISEP

    # Class method separator
    CSEP = '.'

    # Regex-quoted class method separator
    CSEPQ = Regexp.quote CSEP

    # Regular expression to match constant name
    CONSTANTMATCH = /[A-Z]\w*/

    # Regular expression to match namespaces (const A or complex path A::B)
    NAMESPACEMATCH = /(?:(?:#{NSEPQ})?#{CONSTANTMATCH})+/

    # Regular expression to match a method name
    METHODNAMEMATCH = /[a-zA-Z_]\w*[!?=]?|[-+~]\@|<<|>>|=~|===?|<=>|[<>]=?|\*\*|[-\/+%^&*~`|]|\[\]=?/

    # Regular expression to match a fully qualified method def (self.foo, Class.foo).
    METHODMATCH = /(?:(?:#{NAMESPACEMATCH}|[a-z]\w*)\s*(?:#{CSEPQ}|#{NSEPQ})\s*)?#{METHODNAMEMATCH}/

    # All builtin Ruby exception classes for inheritance tree.
    BUILTIN_EXCEPTIONS = ["SecurityError", "Exception", "NoMethodError", "FloatDomainError",
      "IOError", "TypeError", "NotImplementedError", "SystemExit", "Interrupt", "SyntaxError",
      "RangeError", "NoMemoryError", "ArgumentError", "ThreadError", "EOFError", "RuntimeError",
      "ZeroDivisionError", "StandardError", "LoadError", "NameError", "LocalJumpError", "SystemCallError",
      "SignalException", "ScriptError", "SystemStackError", "RegexpError", "IndexError"]
    # All builtin Ruby classes for inheritance tree.
    # @note MatchingData is a 1.8.x legacy class
    BUILTIN_CLASSES = ["TrueClass", "Array", "Dir", "Struct", "UnboundMethod", "Object", "Fixnum", "Float",
      "ThreadGroup", "MatchingData", "MatchData", "Proc", "Binding", "Class", "Time", "Bignum", "NilClass", "Symbol",
      "Numeric", "String", "Data", "MatchData", "Regexp", "Integer", "File", "IO", "Range", "FalseClass",
      "Method", "Continuation", "Thread", "Hash", "Module"] + BUILTIN_EXCEPTIONS
    # All builtin Ruby modules for mixin handling.
    BUILTIN_MODULES = ["ObjectSpace", "Signal", "Marshal", "Kernel", "Process", "GC", "FileTest", "Enumerable",
      "Comparable", "Errno", "Precision", "Math"]
    # All builtin Ruby classes and modules.
    BUILTIN_ALL = BUILTIN_CLASSES + BUILTIN_MODULES

    # Hash of {BUILTIN_EXCEPTIONS} as keys and true as value (for O(1) lookups)
    BUILTIN_EXCEPTIONS_HASH = BUILTIN_EXCEPTIONS.inject({}) {|h,n| h.update(n => true) }

    # +Base+ is the superclass of all code objects recognized by YARD. A code
    # object is any entity in the Ruby language (class, method, module). A
    # DSL might subclass +Base+ to create a new custom object representing
    # a new entity type.
    #
    # == Registry Integration
    # Any created object associated with a namespace is immediately registered
    # with the registry. This allows the Registry to act as an identity map
    # to ensure that no object is represented by more than one Ruby object
    # in memory. A unique {#path} is essential for this identity map to work
    # correctly.
    #
    # == Custom Attributes
    # Code objects allow arbitrary custom attributes to be set using the
    # {#[]=} assignment method.
    #
    # == Namespaces
    # There is a special type of object called a "namespace". These are subclasses
    # of the {NamespaceObject} and represent Ruby entities that can have
    # objects defined within them. Classically these are modules and classes,
    # though a DSL might create a custom {NamespaceObject} to describe a
    # specific set of objects.
    #
    # @abstract This class should not be used directly. Instead, create a
    #   subclass that implements {#path}, {#sep} or {#type}.
    # @see Registry
    # @see #path
    # @see #[]=
    # @see NamespaceObject
    class Base
      # The files the object was defined in. To add a file, use {#add_file}.
      # @return [Array<String>] a list of files
      # @see #add_file
      attr_reader :files

      # The namespace the object is defined in. If the object is in the
      # top level namespace, this is {Registry.root}
      # @return [NamespaceObject] the namespace object
      attr_reader :namespace

      # The source code associated with the object
      # @return [String, nil] source, if present, or nil
      attr_reader :source

      # Language of the source code associated with the object. Defaults to
      # +:ruby+.
      #
      # @return [Symbol] the language type
      attr_accessor :source_type

      # The one line signature representing an object. For a method, this will
      # be of the form "def meth(arguments...)". This is usually the first
      # source line.
      #
      # @return [String] a line of source
      attr_accessor :signature

      # The documentation string associated with the object
      # @return [Docstring] the documentation string
      attr_reader :docstring

      # Marks whether or not the method is conditionally defined at runtime
      # @return [Boolean] true if the method is conditionally defined at runtime
      attr_accessor :dynamic

      # @return [String] the group this object is associated with
      # @since 0.6.0
      attr_accessor :group

      # Is the object defined conditionally at runtime?
      # @see #dynamic
      def dynamic?; @dynamic end

      # @return [Symbol] the visibility of an object (:public, :private, :protected)
      attr_accessor :visibility
      undef visibility=
      def visibility=(v) @visibility = v.to_sym end

      class << self
        # Allocates a new code object
        # @return [Base]
        # @see #initialize
        def new(namespace, name, *args, &block)
          raise ArgumentError, "invalid empty object name" if name.to_s.empty?
          if namespace.is_a?(ConstantObject)
            namespace = Proxy.new(namespace.namespace, namespace.value)
          end

          if name.to_s[0,2] == NSEP
            name = name.to_s[2..-1]
            namespace = Registry.root
          elsif name =~ /(?:#{NSEPQ})([^:]+)$/
            return new(Proxy.new(namespace, $`), $1, *args, &block)
          end

          obj = super(namespace, name, *args)
          existing_obj = Registry.at(obj.path)
          obj = existing_obj if existing_obj && existing_obj.class == self
          yield(obj) if block_given?
          obj
        end

        # Compares the class with subclasses
        #
        # @param [Object] other the other object to compare classes with
        # @return [Boolean] true if other is a subclass of self
        def ===(other)
          other.is_a?(self)
        end
      end

      # Creates a new code object
      #
      # @example Create a method in the root namespace
      #   CodeObjects::Base.new(:root, '#method') # => #<yardoc method #method>
      # @example Create class Z inside namespace X::Y
      #   CodeObjects::Base.new(P("X::Y"), :Z) # or
      #   CodeObjects::Base.new(Registry.root, "X::Y")
      # @param [NamespaceObject] namespace the namespace the object belongs in,
      #   {Registry.root} or :root should be provided if it is associated with
      #   the top level namespace.
      # @param [Symbol, String] name the name (or complex path) of the object.
      # @yield [self] a block to perform any extra initialization on the object
      # @yieldparam [Base] self the newly initialized code object
      # @return [Base] the newly created object
      def initialize(namespace, name, *args, &block)
        if namespace && namespace != :root &&
            !namespace.is_a?(NamespaceObject) && !namespace.is_a?(Proxy)
          raise ArgumentError, "Invalid namespace object: #{namespace}"
        end

        @files = []
        @current_file_has_comments = false
        @name = name.to_sym
        @source_type = :ruby
        @visibility = :public
        @tags = []
        @docstring = Docstring.new('', self)
        @namespace = nil
        self.namespace = namespace
        yield(self) if block_given?
      end

      # The name of the object
      # @param [Boolean] prefix whether to show a prefix. Implement
      #   this in a subclass to define how the prefix is showed.
      # @return [Symbol] if prefix is false, the symbolized name
      # @return [String] if prefix is true, prefix + the name as a String.
      #   This must be implemented by the subclass.
      def name(prefix = false)
        prefix ? @name.to_s : @name
      end

      # Associates a file with a code object, optionally adding the line where it was defined.
      # By convention, '<stdin>' should be used to associate code that comes form standard input.
      #
      # @param [String] file the filename ('<stdin>' for standard input)
      # @param [Fixnum, nil] line the line number where the object lies in the file
      # @param [Boolean] has_comments whether or not the definition has comments associated. This
      #   will allow {#file} to return the definition where the comments were made instead
      #   of any empty definitions that might have been parsed before (module namespaces for instance).
      def add_file(file, line = nil, has_comments = false)
        raise(ArgumentError, "file cannot be nil or empty") if file.nil? || file == ''
        obj = [file.to_s, line]
        return if files.include?(obj)
        if has_comments && !@current_file_has_comments
          @current_file_has_comments = true
          @files.unshift(obj)
        else
          @files << obj # back of the line
        end
      end

      # Returns the filename the object was first parsed at, taking
      # definitions with docstrings first.
      #
      # @return [String] a filename
      def file
        @files.first ? @files.first[0] : nil
      end

      # Returns the line the object was first parsed at (or nil)
      #
      # @return [Fixnum] the line where the object was first defined.
      # @return [nil] if there is no line associated with the object
      def line
        @files.first ? @files.first[1] : nil
      end

      # Tests if another object is equal to this, including a proxy
      # @param [Base, Proxy] other if other is a {Proxy}, tests if
      #   the paths are equal
      # @return [Boolean] whether or not the objects are considered the same
      def equal?(other)
        if other.is_a?(Base) || other.is_a?(Proxy)
          path == other.path
        else
          super
        end
      end
      alias == equal?
      alias eql? equal?

      # @return [Integer] the object's hash value (for equality checking)
      def hash; path.hash end

      # Accesses a custom attribute on the object
      # @param [#to_s] key the name of the custom attribute
      # @return [Object, nil] the custom attribute or nil if not found.
      # @see #[]=
      def [](key)
        if respond_to?(key)
          send(key)
        elsif instance_variable_defined?("@#{key}")
          instance_variable_get("@#{key}")
        end
      end

      # Sets a custom attribute on the object
      # @param [#to_s] key the name of the custom attribute
      # @param [Object] value the value to associate
      # @return [void]
      # @see #[]
      def []=(key, value)
        if respond_to?("#{key}=")
          send("#{key}=", value)
        else
          instance_variable_set("@#{key}", value)
        end
      end

      # @overload dynamic_attr_name
      #   @return the value of attribute named by the method attribute name
      #   @raise [NoMethodError] if no method or custom attribute exists by
      #     the attribute name
      #   @see #[]
      # @overload dynamic_attr_name=(value)
      #   @param value a value to set
      #   @return +value+
      #   @see #[]=
      def method_missing(meth, *args, &block)
        if meth.to_s =~ /=$/
          self[meth.to_s[0..-2]] = args.first
        elsif instance_variable_get("@#{meth}")
          self[meth]
        else
          super
        end
      end

      # Attaches source code to a code object with an optional file location
      #
      # @param [#source, String] statement
      #   the +Parser::Statement+ holding the source code or the raw source
      #   as a +String+ for the definition of the code object only (not the block)
      def source=(statement)
        if statement.respond_to?(:source)
          self.line = statement.line
          self.signature = statement.first_line
          @source = format_source(statement.source.strip)
        else
          @source = format_source(statement.to_s)
        end
      end

      def docstring
        return @docstring if !@docstring_extra
        case @docstring
        when Proxy
          return @docstring_extra
        when Base
          @docstring = @docstring.docstring + @docstring_extra
          @docstring_extra = nil
        end
        @docstring
      end

      # Attaches a docstring to a code object by parsing the comments attached to the statement
      # and filling the {#tags} and {#docstring} methods with the parsed information.
      #
      # @param [String, Array<String>, Docstring] comments
      #   the comments attached to the code object to be parsed
      #   into a docstring and meta tags.
      def docstring=(comments)
        if comments =~ /\A\s*\(see (\S+)\s*\)(?:\s|$)/
          path, extra = $1, $'
          @docstring_extra = Docstring.new(extra, self)
          @docstring = Proxy.new(namespace, path)
        else
          @docstring_extra = nil
          @docstring = Docstring === comments ? comments : Docstring.new(comments, self)
        end
      end

      # Default type is the lowercase class name without the "Object" suffix.
      # Override this method to provide a custom object type
      #
      # @return [Symbol] the type of code object this represents
      def type
        self.class.name.split(/#{NSEPQ}/).last.gsub(/Object$/, '').downcase.to_sym
      end

      # Represents the unique path of the object. The default implementation
      # joins the path of {#namespace} with {#name} via the value of {#sep}.
      # Custom code objects should ensure that the path is unique to the code
      # object by either overriding {#sep} or this method.
      #
      # @example The path of an instance method
      #   MethodObject.new(P("A::B"), :c).path # => "A::B#c"
      # @return [String] the unique path of the object
      # @see #sep
      def path
        @path ||= if parent && !parent.root?
          [parent.path, name.to_s].join(sep)
        else
          name.to_s
        end
      end
      alias_method :to_s, :path

      # @param [Base, String] other another code object (or object path)
      # @return [String] the shortest relative path from this object to +other+
      # @since 0.5.3
      def relative_path(other)
        other = Registry.at(other) if String === other && Registry.at(other)
        same_parent = false
        if other.respond_to?(:path)
          same_parent = other.parent == parent
          other = other.path
        end
        return other unless namespace
        common = [path, other].join(" ").match(/^(\S*)\S*(?: \1\S*)*$/)[1]
        common = path unless common =~ /(\.|::|#)$/
        common = common.sub(/(\.|::|#)[^:#\.]*?$/, '') if same_parent
        if %w(. :).include?(common[-1,1]) || other[common.size,1] == '#'
          suffix = ''
        else
          suffix = '(::|\.)'
        end
        result = other.sub(/^#{Regexp.quote common}#{suffix}/, '')
        result.empty? ? other : result
      end

      # Renders the object using the {Templates::Engine templating system}.
      #
      # @example Formats a class in plaintext
      #   puts P('MyClass').format
      # @example Formats a method in html with rdoc markup
      #   puts P('MyClass#meth').format(:format => :html, :markup => :rdoc)
      # @param [Hash] options a set of options to pass to the template
      # @option options [Symbol] :format (:text) :html, :text or another output format
      # @option options [Symbol] :template (:default) a specific template to use
      # @option options [Symbol] :markup (nil) the markup type (:rdoc, :markdown, :textile)
      # @option options [Serializers::Base] :serializer (nil) see Serializers
      # @return [String] the rendered template
      # @see Templates::Engine#render
      def format(options = {})
        options.merge!(:object => self)
        Templates::Engine.render(options)
      end

      # Inspects the object, returning the type and path
      # @return [String] a string describing the object
      def inspect
        "#<yardoc #{type} #{path}>"
      end

      # Sets the namespace the object is defined in.
      #
      # @param [NamespaceObject, :root, nil] obj the new namespace (:root
      #   for {Registry.root}). If obj is nil, the object is unregistered
      #   from the Registry.
      def namespace=(obj)
        if @namespace
          @namespace.children.delete(self)
          Registry.delete(self)
        end

        @namespace = (obj == :root ? Registry.root : obj)

        if @namespace
          reg_obj = Registry.at(path)
          return if reg_obj && reg_obj.class == self.class
          @namespace.children << self unless @namespace.is_a?(Proxy)
          Registry.register(self)
        end
      end

      alias_method :parent, :namespace
      alias_method :parent=, :namespace=

      # Gets a tag from the {#docstring}
      # @see Docstring#tag
      def tag(name); docstring.tag(name) end

      # Gets a list of tags from the {#docstring}
      # @see Docstring#tags
      def tags(name = nil); docstring.tags(name) end

      # Tests if the {#docstring} has a tag
      # @see Docstring#has_tag?
      def has_tag?(name); docstring.has_tag?(name) end

      # @return whether or not this object is a RootObject
      def root?; false end

      protected

      # Override this method with a custom component separator. For instance,
      # {MethodObject} implements sep as '#' or '.' (depending on if the
      # method is instance or class respectively). {#path} depends on this
      # value to generate the full path in the form: namespace.path + sep + name
      #
      # @return [String] the component that separates the namespace path
      #   and the name (default is {NSEP})
      def sep; NSEP end

      # Formats source code by removing leading indentation
      #
      # @param [String] source the source code to format
      # @return [String] formatted source
      def format_source(source)
        source.chomp!
        last = source.split(/\r?\n/).last
        indent = last ? last[/^([ \t]*)/, 1].length : 0
        source.gsub(/^[ \t]{#{indent}}/, '')
      end
    end
  end
end
