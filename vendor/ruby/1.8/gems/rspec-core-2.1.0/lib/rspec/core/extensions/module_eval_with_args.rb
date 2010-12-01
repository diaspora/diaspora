module RSpec
  module Core
    module Extensions
      module ModuleEvalWithArgs
        include InstanceEvalWithArgs

        def module_eval_with_args(*args, &block)
          # ruby > 1.8.6
          return module_exec(*args, &block) if respond_to?(:module_exec)

          # If there are no args and the block doesn't expect any, there's no
          # need to fake module_exec with our hack below.
          # Notes:
          #   * lambda {      }.arity # => -1
          #   * lambda { ||   }.arity # =>  0
          #   * lambda { |*a| }.arity # => -1
          return module_eval(&block) if block.arity < 1 && args.size.zero?

          orig_singleton_methods = singleton_methods
          instance_eval_with_args(*args, &block)

          # The only difference between instance_eval and module_eval is static method defs.
          #   * `def foo` in instance_eval defines a singleton method on the instance
          #   * `def foo` in class/module_eval defines an instance method for the class/module
          # Here we deal with this difference by defining an instance method for
          # each new singleton method.
          # This has the side effect of duplicating methods (all new class methods will
          # become instance methods and vice versa), but I don't see a way around it...
          (singleton_methods - orig_singleton_methods).each { |m| define_method(m, &method(m)) }
        end
      end
    end
  end
end
