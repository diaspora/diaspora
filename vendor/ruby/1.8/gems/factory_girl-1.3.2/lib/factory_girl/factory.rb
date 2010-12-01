class Factory
  undef :id   if Factory.instance_methods.include?('id')
  undef :type if Factory.instance_methods.include?('type')

  # Raised when a factory is defined that attempts to instantiate itself.
  class AssociationDefinitionError < RuntimeError
  end

  # Raised when a callback is defined that has an invalid name
  class InvalidCallbackNameError < RuntimeError
  end

  # Raised when a factory is defined with the same name as a previously-defined factory.
  class DuplicateDefinitionError < RuntimeError
  end

  class << self
    attr_accessor :factories #:nodoc:

    # An Array of strings specifying locations that should be searched for
    # factory definitions. By default, factory_girl will attempt to require
    # "factories," "test/factories," and "spec/factories." Only the first
    # existing file will be loaded.
    attr_accessor :definition_file_paths
  end

  self.factories = {}
  self.definition_file_paths = %w(factories test/factories spec/factories)

  attr_reader :factory_name #:nodoc:
  attr_reader :attributes #:nodoc:

  # Defines a new factory that can be used by the build strategies (create and
  # build) to build new objects.
  #
  # Arguments:
  # * name: +Symbol+ or +String+
  #   A unique name used to identify this factory.
  # * options: +Hash+
  #
  # Options:
  # * class: +Symbol+, +Class+, or +String+
  #   The class that will be used when generating instances for this factory. If not specified, the class will be guessed from the factory name.
  # * parent: +Symbol+
  #   The parent factory. If specified, the attributes from the parent
  #   factory will be copied to the current one with an ability to override
  #   them.
  # * default_strategy: +Symbol+
  #   The strategy that will be used by the Factory shortcut method.
  #   Defaults to :create.
  #
  # Yields: +Factory+
  # The newly created factory.
  def self.define (name, options = {})
    instance = Factory.new(name, options)
    yield(instance)
    if parent = options.delete(:parent)
      instance.inherit_from(Factory.factory_by_name(parent))
    end
    if self.factories[instance.factory_name]
      raise DuplicateDefinitionError, "Factory already defined: #{name}"
    end
    self.factories[instance.factory_name] = instance
  end

  def class_name #:nodoc:
    @options[:class] || factory_name
  end

  def build_class #:nodoc:
    @build_class ||= class_for(class_name)
  end

  def default_strategy #:nodoc:
    @options[:default_strategy] || :create
  end

  def initialize (name, options = {}) #:nodoc:
    assert_valid_options(options)
    @factory_name = factory_name_for(name)
    @options      = options
    @attributes   = []
  end

  def inherit_from(parent) #:nodoc:
    @options[:class]            ||= parent.class_name
    @options[:default_strategy] ||= parent.default_strategy
    parent.attributes.each do |attribute|
      unless attribute_defined?(attribute.name)
        @attributes << attribute.clone
      end
    end
  end

  # Adds an attribute that should be assigned on generated instances for this
  # factory.
  #
  # This method should be called with either a value or block, but not both. If
  # called with a block, the attribute will be generated "lazily," whenever an
  # instance is generated. Lazy attribute blocks will not be called if that
  # attribute is overridden for a specific instance.
  #
  # When defining lazy attributes, an instance of Factory::Proxy will
  # be yielded, allowing associations to be built using the correct build
  # strategy.
  #
  # Arguments:
  # * name: +Symbol+ or +String+
  #   The name of this attribute. This will be assigned using :"#{name}=" for
  #   generated instances.
  # * value: +Object+
  #   If no block is given, this value will be used for this attribute.
  def add_attribute (name, value = nil, &block)
    if block_given?
      if value
        raise AttributeDefinitionError, "Both value and block given"
      else
        attribute = Attribute::Dynamic.new(name, block)
      end
    else
      attribute = Attribute::Static.new(name, value)
    end

    if attribute_defined?(attribute.name)
      raise AttributeDefinitionError, "Attribute already defined: #{name}"
    end

    @attributes << attribute
  end

  # Calls add_attribute using the missing method name as the name of the
  # attribute, so that:
  #
  #   Factory.define :user do |f|
  #     f.name 'Billy Idol'
  #   end
  #
  # and:
  #
  #   Factory.define :user do |f|
  #     f.add_attribute :name, 'Billy Idol'
  #   end
  #
  # are equivilent.
  def method_missing (name, *args, &block)
    add_attribute(name, *args, &block)
  end

  # Adds an attribute that builds an association. The associated instance will
  # be built using the same build strategy as the parent instance.
  #
  # Example:
  #   Factory.define :user do |f|
  #     f.name 'Joey'
  #   end
  #
  #   Factory.define :post do |f|
  #     f.association :author, :factory => :user
  #   end
  #
  # Arguments:
  # * name: +Symbol+
  #   The name of this attribute.
  # * options: +Hash+
  #
  # Options:
  # * factory: +Symbol+ or +String+
  #    The name of the factory to use when building the associated instance.
  #    If no name is given, the name of the attribute is assumed to be the
  #    name of the factory. For example, a "user" association will by
  #    default use the "user" factory.
  def association (name, options = {})
    factory_name = options.delete(:factory) || name
    if factory_name_for(factory_name) == self.factory_name
      raise AssociationDefinitionError, "Self-referencing association '#{name}' in factory '#{self.factory_name}'"
    end
    @attributes << Attribute::Association.new(name, factory_name, options)
  end

  # Adds an attribute that will have unique values generated by a sequence with
  # a specified format.
  #
  # The result of:
  #   Factory.define :user do |f|
  #    f.sequence(:email) { |n| "person#{n}@example.com" }
  #   end
  #
  # Is equal to:
  #   Factory.sequence(:email) { |n| "person#{n}@example.com" }
  #
  #   Factory.define :user do |f|
  #    f.email { Factory.next(:email) }
  #   end
  #
  # Except that no globally available sequence will be defined.
  def sequence (name, &block)
    s = Sequence.new(&block)
    add_attribute(name) { s.next }
  end

  def after_build(&block)
    callback(:after_build, &block)
  end

  def after_create(&block)
    callback(:after_create, &block)
  end

  def after_stub(&block)
    callback(:after_stub, &block)
  end

  def callback(name, &block)
    unless [:after_build, :after_create, :after_stub].include?(name.to_sym)
      raise InvalidCallbackNameError, "#{name} is not a valid callback name. Valid callback names are :after_build, :after_create, and :after_stub"
    end
    @attributes << Attribute::Callback.new(name.to_sym, block)
  end

  # Generates and returns a Hash of attributes from this factory. Attributes
  # can be individually overridden by passing in a Hash of attribute => value
  # pairs.
  #
  # Arguments:
  # * name: +Symbol+ or +String+
  #   The name of the factory that should be used.
  # * overrides: +Hash+
  #   Attributes to overwrite for this set.
  #
  # Returns: +Hash+
  # A set of attributes that can be used to build an instance of the class
  # this factory generates.
  def self.attributes_for (name, overrides = {})
    factory_by_name(name).run(Proxy::AttributesFor, overrides)
  end

  # Generates and returns an instance from this factory. Attributes can be
  # individually overridden by passing in a Hash of attribute => value pairs.
  #
  # Arguments:
  # * name: +Symbol+ or +String+
  #   The name of the factory that should be used.
  # * overrides: +Hash+
  #   Attributes to overwrite for this instance.
  #
  # Returns: +Object+
  # An instance of the class this factory generates, with generated attributes
  # assigned.
  def self.build (name, overrides = {})
    factory_by_name(name).run(Proxy::Build, overrides)
  end

  # Generates, saves, and returns an instance from this factory. Attributes can
  # be individually overridden by passing in a Hash of attribute => value
  # pairs.
  #
  # Instances are saved using the +save!+ method, so ActiveRecord models will
  # raise ActiveRecord::RecordInvalid exceptions for invalid attribute sets.
  #
  # Arguments:
  # * name: +Symbol+ or +String+
  #   The name of the factory that should be used.
  # * overrides: +Hash+
  #   Attributes to overwrite for this instance.
  #
  # Returns: +Object+
  # A saved instance of the class this factory generates, with generated
  # attributes assigned.
  def self.create (name, overrides = {})
    factory_by_name(name).run(Proxy::Create, overrides)
  end

  # Generates and returns an object with all attributes from this factory
  # stubbed out. Attributes can be individually overridden by passing in a Hash
  # of attribute => value pairs.
  #
  # Arguments:
  # * name: +Symbol+ or +String+
  #   The name of the factory that should be used.
  # * overrides: +Hash+
  #   Attributes to overwrite for this instance.
  #
  # Returns: +Object+
  # An object with generated attributes stubbed out.
  def self.stub (name, overrides = {})
    factory_by_name(name).run(Proxy::Stub, overrides)
  end

  # Executes the default strategy for the given factory. This is usually create,
  # but it can be overridden for each factory.
  #
  # Arguments:
  # * name: +Symbol+ or +String+
  #   The name of the factory that should be used.
  # * overrides: +Hash+
  #   Attributes to overwrite for this instance.
  #
  # Returns: +Object+
  # The result of the default strategy.
  def self.default_strategy (name, overrides = {})
    self.send(factory_by_name(name).default_strategy, name, overrides)
  end

  def self.find_definitions #:nodoc:
    definition_file_paths.each do |path|
      full_path = File.expand_path(path)
      require("#{full_path}.rb") if File.exists?("#{full_path}.rb")

      if File.directory?(full_path)
        Dir[File.join(full_path, '*.rb')].each do |file|
          require(file)
        end
      end
    end
  end

  def run (proxy_class, overrides) #:nodoc:
    proxy = proxy_class.new(build_class)
    overrides = symbolize_keys(overrides)
    overrides.each {|attr, val| proxy.set(attr, val) }
    passed_keys = overrides.keys.collect {|k| Factory.aliases_for(k) }.flatten
    @attributes.each do |attribute|
      unless passed_keys.include?(attribute.name)
        attribute.add_to(proxy)
      end
    end
    proxy.result
  end

  def self.factory_by_name (name)
    factories[name.to_sym] or raise ArgumentError.new("No such factory: #{name.to_s}")
  end

  def human_name(*args, &block)
    if args.size == 0 && block.nil?
      factory_name.to_s.gsub('_', ' ')
    else
      add_attribute(:human_name, *args, &block)
    end
  end

  def associations
    attributes.select {|attribute| attribute.is_a?(Attribute::Association) }
  end

  private

  def class_for (class_or_to_s)
    if class_or_to_s.respond_to?(:to_sym)
      class_name = variable_name_to_class_name(class_or_to_s)
      class_name.split('::').inject(Object) do |object, string|
        object.const_get(string)
      end
    else
      class_or_to_s
    end
  end

  def factory_name_for (class_or_to_s)
    if class_or_to_s.respond_to?(:to_sym)
      class_or_to_s.to_sym
    else
      class_name_to_variable_name(class_or_to_s).to_sym
    end
  end

  def attribute_defined? (name)
    !@attributes.detect {|attr| attr.name == name && !attr.is_a?(Factory::Attribute::Callback) }.nil?
  end

  def assert_valid_options(options)
    invalid_keys = options.keys - [:class, :parent, :default_strategy]
    unless invalid_keys == []
      raise ArgumentError, "Unknown arguments: #{invalid_keys.inspect}"
    end
    assert_valid_strategy(options[:default_strategy]) if options[:default_strategy]
  end

  def assert_valid_strategy(strategy)
    unless Factory::Proxy.const_defined? variable_name_to_class_name(strategy)
      raise ArgumentError, "Unknown strategy: #{strategy}"
    end
  end

  # Based on ActiveSupport's underscore inflector
  def class_name_to_variable_name(name)
    name.to_s.gsub(/::/, '/').
      gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
      gsub(/([a-z\d])([A-Z])/,'\1_\2').
      tr("-", "_").
      downcase
  end

  # Based on ActiveSupport's camelize inflector
  def variable_name_to_class_name(name)
    name.to_s.
      gsub(/\/(.?)/) { "::#{$1.upcase}" }.
      gsub(/(?:^|_)(.)/) { $1.upcase }
  end

  # From ActiveSupport
  def symbolize_keys(hash)
    hash.inject({}) do |options, (key, value)|
      options[(key.to_sym rescue key) || key] = value
      options
    end
  end

end
