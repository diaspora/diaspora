require 'active_support/core_ext/array/extract_options'
require 'active_support/core_ext/array/wrap'
require 'active_support/core_ext/class/attribute'
require 'active_support/core_ext/hash/keys'
require 'active_support/core_ext/hash/except'
require 'active_model/errors'
require 'active_model/validations/callbacks'

module ActiveModel

  # == Active Model Validations
  #
  # Provides a full validation framework to your objects.
  #
  # A minimal implementation could be:
  #
  #   class Person
  #     include ActiveModel::Validations
  #
  #     attr_accessor :first_name, :last_name
  #
  #     validates_each :first_name, :last_name do |record, attr, value|
  #       record.errors.add attr, 'starts with z.' if value.to_s[0] == ?z
  #     end
  #   end
  #
  # Which provides you with the full standard validation stack that you
  # know from Active Record:
  #
  #   person = Person.new
  #   person.valid?                   # => true
  #   person.invalid?                 # => false
  #
  #   person.first_name = 'zoolander'
  #   person.valid?                   # => false
  #   person.invalid?                 # => true
  #   person.errors                   # => #<OrderedHash {:first_name=>["starts with z."]}>
  #
  # Note that ActiveModel::Validations automatically adds an +errors+ method
  # to your instances initialized with a new ActiveModel::Errors object, so
  # there is no need for you to do this manually.
  #
  module Validations
    extend ActiveSupport::Concern
    include ActiveSupport::Callbacks

    included do
      extend ActiveModel::Translation

      extend  HelperMethods
      include HelperMethods

      attr_accessor :validation_context
      define_callbacks :validate, :scope => :name

      class_attribute :_validators
      self._validators = Hash.new { |h,k| h[k] = [] }
    end

    module ClassMethods
      # Validates each attribute against a block.
      #
      #   class Person
      #     include ActiveModel::Validations
      #
      #     attr_accessor :first_name, :last_name
      #
      #     validates_each :first_name, :last_name do |record, attr, value|
      #       record.errors.add attr, 'starts with z.' if value.to_s[0] == ?z
      #     end
      #   end
      #
      # Options:
      # * <tt>:on</tt> - Specifies when this validation is active (default is
      #   <tt>:save</tt>, other options <tt>:create</tt>, <tt>:update</tt>).
      # * <tt>:allow_nil</tt> - Skip validation if attribute is +nil+.
      # * <tt>:allow_blank</tt> - Skip validation if attribute is blank.
      # * <tt>:if</tt> - Specifies a method, proc or string to call to determine
      #   if the validation should occur (e.g. <tt>:if => :allow_validation</tt>,
      #   or <tt>:if => Proc.new { |user| user.signup_step > 2 }</tt>). The method,
      #   proc or string should return or evaluate to a true or false value.
      # * <tt>:unless</tt> - Specifies a method, proc or string to call to determine if the validation should
      #   not occur (e.g. <tt>:unless => :skip_validation</tt>, or
      #   <tt>:unless => Proc.new { |user| user.signup_step <= 2 }</tt>).  The
      #   method, proc or string should return or evaluate to a true or false value.
      def validates_each(*attr_names, &block)
        options = attr_names.extract_options!.symbolize_keys
        validates_with BlockValidator, options.merge(:attributes => attr_names.flatten), &block
      end

      # Adds a validation method or block to the class. This is useful when
      # overriding the +validate+ instance method becomes too unwieldy and
      # you're looking for more descriptive declaration of your validations.
      #
      # This can be done with a symbol pointing to a method:
      #
      #   class Comment
      #     include ActiveModel::Validations
      #
      #     validate :must_be_friends
      #
      #     def must_be_friends
      #       errors.add_to_base("Must be friends to leave a comment") unless commenter.friend_of?(commentee)
      #     end
      #   end
      #
      # Or with a block which is passed with the current record to be validated:
      #
      #   class Comment
      #     include ActiveModel::Validations
      #
      #     validate do |comment|
      #       comment.must_be_friends
      #     end
      #
      #     def must_be_friends
      #       errors.add_to_base("Must be friends to leave a comment") unless commenter.friend_of?(commentee)
      #     end
      #   end
      #
      def validate(*args, &block)
        options = args.extract_options!
        if options.key?(:on)
          options = options.dup
          options[:if] = Array.wrap(options[:if])
          options[:if] << "validation_context == :#{options[:on]}"
        end
        args << options
        set_callback(:validate, *args, &block)
      end

      [:create, :update].each do |type|
        class_eval <<-RUBY
          def validate_on_#{type}(*args, &block)
            msg = "validate_on_#{type} is deprecated. Please use validate(args, :on => :#{type})"
            ActiveSupport::Deprecation.warn(msg, caller)
            options = args.extract_options!
            options[:on] = :#{type}
            validate(*args.push(options), &block)
          end
        RUBY
      end

      # List all validators that are being used to validate the model using
      # +validates_with+ method.
      def validators
        _validators.values.flatten.uniq
      end

      # List all validators that being used to validate a specific attribute.
      def validators_on(attribute)
        _validators[attribute.to_sym]
      end

      # Check if method is an attribute method or not.
      def attribute_method?(attribute)
        method_defined?(attribute)
      end

      # Copy validators on inheritance.
      def inherited(base)
        dup = _validators.dup
        base._validators = dup.each { |k, v| dup[k] = v.dup }
        super
      end
    end

    # Returns the Errors object that holds all information about attribute error messages.
    def errors
      @errors ||= Errors.new(self)
    end

    # Runs all the specified validations and returns true if no errors were added
    # otherwise false. Context can optionally be supplied to define which callbacks
    # to test against (the context is defined on the validations using :on).
    def valid?(context = nil)
      current_context, self.validation_context = validation_context, context
      errors.clear
      run_validations!
    ensure
      self.validation_context = current_context
    end

    # Performs the opposite of <tt>valid?</tt>. Returns true if errors were added,
    # false otherwise.
    def invalid?(context = nil)
      !valid?(context)
    end

    # Hook method defining how an attribute value should be retrieved. By default
    # this is assumed to be an instance named after the attribute. Override this
    # method in subclasses should you need to retrieve the value for a given
    # attribute differently:
    #
    #   class MyClass
    #     include ActiveModel::Validations
    #
    #     def initialize(data = {})
    #       @data = data
    #     end
    #
    #     def read_attribute_for_validation(key)
    #       @data[key]
    #     end
    #   end
    #
    alias :read_attribute_for_validation :send

  protected

    def run_validations!
      _run_validate_callbacks
      errors.empty?
    end
  end
end

Dir[File.dirname(__FILE__) + "/validations/*.rb"].sort.each do |path|
  filename = File.basename(path)
  require "active_model/validations/#{filename}"
end
