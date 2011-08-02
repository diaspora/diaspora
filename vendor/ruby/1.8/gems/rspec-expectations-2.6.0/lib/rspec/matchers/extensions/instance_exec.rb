module RSpec
  module Matchers
    module InstanceExec
      unless respond_to?(:instance_exec)
        # based on Bounded Spec InstanceExec (Mauricio Fernandez)
        # http://eigenclass.org/hiki/bounded+space+instance_exec
        # - uses singleton_class of matcher instead of global
        #   InstanceExecHelper module
        # - this keeps it scoped to this class only, which is the
        #   only place we need it
        # - only necessary for ruby 1.8.6
        def instance_exec(*args, &block)
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
