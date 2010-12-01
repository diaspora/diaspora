module RSpec
  module Core
    module Extensions
      module InstanceEvalWithArgs
        # based on Bounded Spec InstanceExec (Mauricio Fernandez)
        # http://eigenclass.org/hiki/bounded+space+instance_exec
        # - uses singleton_class instead of global InstanceExecHelper module
        # - this keeps it scoped to classes/modules that include this module
        # - only necessary for ruby 1.8.6
        def instance_eval_with_args(*args, &block)
          return instance_exec(*args, &block) if respond_to?(:instance_exec)

          # If there are no args and the block doesn't expect any, there's no
          # need to fake instance_exec with our hack below.
          # Notes:
          #   * lambda { }.arity # => -1
          #   * lambda { || }.arity # => 0
          #   * lambda { |*a| }.arity # -1
          return instance_eval(&block) if block.arity < 1 && args.size.zero?

          singleton_class = (class << self; self; end)
          begin
            orig_critical, Thread.critical = Thread.critical, true
            n = 0
            n += 1 while respond_to?(method_name="__instance_exec#{n}")
            singleton_class.module_eval{ define_method(method_name, &block) }
          ensure
            Thread.critical = orig_critical
          end
          begin
            return send(method_name, *args)
          ensure
            singleton_class.module_eval{ remove_method(method_name) } rescue nil
          end
        end
      end
    end
  end
end
