require 'active_support/core_ext/array/wrap'
require 'active_support/callbacks'

module ActiveModel
  # == Active Model Callbacks
  #
  # Provides an interface for any class to have Active Record like callbacks.
  #
  # Like the Active Record methods, the callback chain is aborted as soon as
  # one of the methods in the chain returns false.
  #
  # First, extend ActiveModel::Callbacks from the class you are creating:
  #
  #   class MyModel
  #     extend ActiveModel::Callbacks
  #   end
  #
  # Then define a list of methods that you want callbacks attached to:
  #
  #   define_model_callbacks :create, :update
  #
  # This will provide all three standard callbacks (before, around and after) for
  # both the :create and :update methods. To implement, you need to wrap the methods
  # you want callbacks on in a block so that the callbacks get a chance to fire:
  #
  #   def create
  #     _run_create_callbacks do
  #       # Your create action methods here
  #     end
  #   end
  #
  # The _run_<method_name>_callbacks methods are dynamically created when you extend
  # the <tt>ActiveModel::Callbacks</tt> module.
  #
  # Then in your class, you can use the +before_create+, +after_create+ and +around_create+
  # methods, just as you would in an Active Record module.
  #
  #   before_create :action_before_create
  #
  #   def action_before_create
  #     # Your code here
  #   end
  #
  # You can choose not to have all three callbacks by passing a hash to the
  # define_model_callbacks method.
  #
  #   define_model_callbacks :create, :only => :after, :before
  #
  # Would only create the after_create and before_create callback methods in your
  # class.
  module Callbacks
    def self.extended(base)
      base.class_eval do
        include ActiveSupport::Callbacks
      end
    end

    # define_model_callbacks accepts the same options define_callbacks does, in case
    # you want to overwrite a default. Besides that, it also accepts an :only option,
    # where you can choose if you want all types (before, around or after) or just some.
    #
    #   define_model_callbacks :initializer, :only => :after
    #
    # Note, the <tt>:only => <type></tt> hash will apply to all callbacks defined on
    # that method call.  To get around this you can call the define_model_callbacks
    # method as many times as you need.
    #
    #   define_model_callbacks :create, :only => :after
    #   define_model_callbacks :update, :only => :before
    #   define_model_callbacks :destroy, :only => :around
    #
    # Would create +after_create+, +before_update+ and +around_destroy+ methods only.
    #
    # You can pass in a class to before_<type>, after_<type> and around_<type>, in which
    # case the callback will call that class's <action>_<type> method passing the object
    # that the callback is being called on.
    #
    #   class MyModel
    #     extend ActiveModel::Callbacks
    #     define_model_callbacks :create
    #
    #     before_create AnotherClass
    #   end
    #
    #   class AnotherClass
    #     def self.before_create( obj )
    #       # obj is the MyModel instance that the callback is being called on
    #     end
    #   end
    #
    def define_model_callbacks(*callbacks)
      options = callbacks.extract_options!
      options = {
         :terminator => "result == false",
         :scope => [:kind, :name],
         :only => [:before, :around, :after]
      }.merge(options)

      types   = Array.wrap(options.delete(:only))

      callbacks.each do |callback|
        define_callbacks(callback, options)

        types.each do |type|
          send(:"_define_#{type}_model_callback", self, callback)
        end
      end
    end

    def _define_before_model_callback(klass, callback) #:nodoc:
      klass.class_eval <<-CALLBACK, __FILE__, __LINE__ + 1
        def self.before_#{callback}(*args, &block)
          set_callback(:#{callback}, :before, *args, &block)
        end
      CALLBACK
    end

    def _define_around_model_callback(klass, callback) #:nodoc:
      klass.class_eval <<-CALLBACK, __FILE__, __LINE__ + 1
        def self.around_#{callback}(*args, &block)
          set_callback(:#{callback}, :around, *args, &block)
        end
      CALLBACK
    end

    def _define_after_model_callback(klass, callback) #:nodoc:
      klass.class_eval <<-CALLBACK, __FILE__, __LINE__ + 1
        def self.after_#{callback}(*args, &block)
          options = args.extract_options!
          options[:prepend] = true
          options[:if] = Array.wrap(options[:if]) << "!halted && value != false"
          set_callback(:#{callback}, :after, *(args << options), &block)
        end
      CALLBACK
    end
  end
end
