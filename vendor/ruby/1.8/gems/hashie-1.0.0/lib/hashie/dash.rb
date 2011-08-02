require 'hashie/hash'
require 'set'

module Hashie
  # A Dash is a 'defined' or 'discrete' Hash, that is, a Hash
  # that has a set of defined keys that are accessible (with
  # optional defaults) and only those keys may be set or read.
  #
  # Dashes are useful when you need to create a very simple
  # lightweight data object that needs even fewer options and
  # resources than something like a DataMapper resource.
  #
  # It is preferrable to a Struct because of the in-class
  # API for defining properties as well as per-property defaults.
  class Dash < Hashie::Hash
    include Hashie::PrettyInspect
    alias_method :to_s, :inspect

    # Defines a property on the Dash. Options are
    # as follows:
    #
    # * <tt>:default</tt> - Specify a default value for this property,
    #   to be returned before a value is set on the property in a new
    #   Dash.
    #
    def self.property(property_name, options = {})
      property_name = property_name.to_sym

      self.properties << property_name

      if options.has_key?(:default)
        self.defaults[property_name] = options[:default] 
      elsif self.defaults.has_key?(property_name)
        self.defaults.delete property_name
      end

      unless instance_methods.map { |m| m.to_s }.include?("#{property_name}=")
        class_eval <<-ACCESSORS
          def #{property_name}(&block)
            self.[](#{property_name.to_s.inspect}, &block)
          end

          def #{property_name}=(value)
            self.[]=(#{property_name.to_s.inspect}, value)
          end
        ACCESSORS
      end

      if defined? @subclasses
        @subclasses.each { |klass| klass.property(property_name, options) }
      end
    end

    class << self
      attr_reader :properties, :defaults
    end
    instance_variable_set('@properties', Set.new)
    instance_variable_set('@defaults', {})

    def self.inherited(klass)
      super
      (@subclasses ||= Set.new) << klass
      klass.instance_variable_set('@properties', self.properties.dup)
      klass.instance_variable_set('@defaults', self.defaults.dup)
    end

    # Check to see if the specified property has already been
    # defined.
    def self.property?(name)
      properties.include? name.to_sym
    end

    # You may initialize a Dash with an attributes hash
    # just like you would many other kinds of data objects.
    def initialize(attributes = {}, &block)
      super(&block)

      self.class.defaults.each_pair do |prop, value|
        self[prop] = value
      end

      attributes.each_pair do |att, value|
        self[att] = value
      end if attributes
    end

    alias_method :_regular_reader, :[]
    alias_method :_regular_writer, :[]=
    private :_regular_reader, :_regular_writer

    # Retrieve a value from the Dash (will return the
    # property's default value if it hasn't been set).
    def [](property)
      assert_property_exists! property
      value = super(property.to_s)
      yield value if block_given?
      value
    end

    # Set a value on the Dash in a Hash-like way. Only works
    # on pre-existing properties.
    def []=(property, value)
      assert_property_exists! property
      super(property.to_s, value)
    end

    private

      def assert_property_exists!(property)
        unless self.class.property?(property)
          raise NoMethodError, "The property '#{property}' is not defined for this Dash."
        end
      end
  end
end
