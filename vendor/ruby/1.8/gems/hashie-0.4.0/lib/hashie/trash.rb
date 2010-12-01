require 'hashie/dash'

module Hashie
  # A Trash is a 'translated' Dash where the keys can be remapped from a source
  # hash.
  #
  # Trashes are useful when you need to read data from another application,
  # such as a Java api, where the keys are named differently from how we would
  # in Ruby.
  class Trash < Hashie::Dash

    # Defines a property on the Trash. Options are as follows:
    #
    # * <tt>:default</tt> - Specify a default value for this property, to be
    # returned before a value is set on the property in a new Dash.
    # * <tt>:from</tt> - Specify the original key name that will be write only.
    def self.property(property_name, options = {})
      super

      if options[:from]
        translations << options[:from].to_sym
        class_eval <<-RUBY
          def #{options[:from]}=(val)
            self[:#{property_name}] = val
          end
        RUBY
      end
    end

    # Set a value on the Dash in a Hash-like way. Only works
    # on pre-existing properties.
    def []=(property, value)
      if self.class.translations.include? property.to_sym
        send("#{property}=", value)
      elsif property_exists? property
        super
      end
    end

    private

    def self.translations
      @translations ||= []
    end

    # Raises an NoMethodError if the property doesn't exist
    #
    def property_exists?(property)
      unless self.class.property?(property.to_sym)
        raise NoMethodError, "The property '#{property}' is not defined for this Trash."
      end
      true
    end
  end
end
