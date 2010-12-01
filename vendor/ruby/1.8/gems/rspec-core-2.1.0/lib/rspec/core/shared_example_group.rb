module RSpec
  module Core
    module SharedExampleGroup

      def share_examples_for(name, &block)
        ensure_shared_example_group_name_not_taken(name)
        RSpec.world.shared_example_groups[name] = block
      end

      def share_as(name, &block)
        if Object.const_defined?(name)
          mod = Object.const_get(name)
          raise_name_error unless mod.created_from_caller(caller)
        end

        mod = Module.new do
          @shared_block = block
          @caller_line = caller.last

          def self.created_from_caller(other_caller)
            @caller_line == other_caller.last
          end

          def self.included(kls)
            kls.describe(&@shared_block)
            kls.children.first.metadata[:shared_group_name] = name
          end
        end

        shared_const = Object.const_set(name, mod)
        RSpec.world.shared_example_groups[shared_const] = block
      end

      alias :shared_examples_for :share_examples_for

    private

      def raise_name_error
        raise NameError, "The first argument (#{name}) to share_as must be a legal name for a constant not already in use."
      end

      def ensure_shared_example_group_name_not_taken(name)
        if RSpec.world.shared_example_groups.has_key?(name)
          raise ArgumentError.new("Shared example group '#{name}' already exists")
        end
      end

    end
  end
end

include RSpec::Core::SharedExampleGroup
