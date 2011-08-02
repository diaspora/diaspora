module ActiveModel
  module Validations
    module HelperMethods
      private
        def _merge_attributes(attr_names)
          options = attr_names.extract_options!
          options.merge(:attributes => attr_names.flatten)
        end
    end

    module ClassMethods
      # Passes the record off to the class or classes specified and allows them
      # to add errors based on more complex conditions.
      #
      #   class Person
      #     include ActiveModel::Validations
      #     validates_with MyValidator
      #   end
      #
      #   class MyValidator < ActiveModel::Validator
      #     def validate(record)
      #       if some_complex_logic
      #         record.errors[:base] << "This record is invalid"
      #       end
      #     end
      #
      #     private
      #       def some_complex_logic
      #         # ...
      #       end
      #   end
      #
      # You may also pass it multiple classes, like so:
      #
      #   class Person
      #     include ActiveModel::Validations
      #     validates_with MyValidator, MyOtherValidator, :on => :create
      #   end
      #
      # Configuration options:
      # * <tt>on</tt> - Specifies when this validation is active
      #   (<tt>:create</tt> or <tt>:update</tt>
      # * <tt>if</tt> - Specifies a method, proc or string to call to determine
      #   if the validation should occur (e.g. <tt>:if => :allow_validation</tt>,
      #   or <tt>:if => Proc.new { |user| user.signup_step > 2 }</tt>).
      #   The method, proc or string should return or evaluate to a true or false value.
      # * <tt>unless</tt> - Specifies a method, proc or string to call to
      #   determine if the validation should not occur
      #   (e.g. <tt>:unless => :skip_validation</tt>, or
      #   <tt>:unless => Proc.new { |user| user.signup_step <= 2 }</tt>).
      #   The method, proc or string should return or evaluate to a true or false value.
      #
      # If you pass any additional configuration options, they will be passed
      # to the class and available as <tt>options</tt>:
      #
      #   class Person
      #     include ActiveModel::Validations
      #     validates_with MyValidator, :my_custom_key => "my custom value"
      #   end
      #
      #   class MyValidator < ActiveModel::Validator
      #     def validate(record)
      #       options[:my_custom_key] # => "my custom value"
      #     end
      #   end
      #
      def validates_with(*args, &block)
        options = args.extract_options!
        args.each do |klass|
          validator = klass.new(options, &block)
          validator.setup(self) if validator.respond_to?(:setup)

          if validator.respond_to?(:attributes) && !validator.attributes.empty?
            validator.attributes.each do |attribute|
              _validators[attribute.to_sym] << validator
            end
          else
            _validators[nil] << validator
          end

          validate(validator, options)
        end
      end
    end

    # Passes the record off to the class or classes specified and allows them
    # to add errors based on more complex conditions.
    #
    #   class Person
    #     include ActiveModel::Validations
    #
    #     validates :instance_validations
    #
    #     def instance_validations
    #       validates_with MyValidator
    #     end
    #   end
    #
    # Please consult the class method documentation for more information on
    # creating your own validator.
    #
    # You may also pass it multiple classes, like so:
    #
    #   class Person
    #     include ActiveModel::Validations
    #
    #     validates :instance_validations, :on => :create
    #
    #     def instance_validations
    #       validates_with MyValidator, MyOtherValidator
    #     end
    #   end
    #
    # Standard configuration options (:on, :if and :unless), which are
    # available on the class version of validates_with, should instead be
    # placed on the <tt>validates</tt> method as these are applied and tested
    # in the callback
    #
    # If you pass any additional configuration options, they will be passed
    # to the class and available as <tt>options</tt>, please refer to the
    # class version of this method for more information
    #
    def validates_with(*args, &block)
      options = args.extract_options!
      args.each do |klass|
        validator = klass.new(options, &block)
        validator.validate(self)
      end
    end
  end
end