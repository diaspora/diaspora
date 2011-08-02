module RSpec
  module Mocks
    module AnyInstance
      class Chain
        [
          :with, :and_return, :and_raise, :and_yield,
          :once, :twice, :any_number_of_times,
          :exactly, :times, :never,
          :at_least, :at_most
          ].each do |method_name|
            class_eval(<<-EOM, __FILE__, __LINE__)
              def #{method_name}(*args, &block)
                record(:#{method_name}, *args, &block)
              end
            EOM
        end

        def playback!(instance)
          messages.inject(instance) do |instance, message|
            instance.send(*message.first, &message.last)
          end
        end

        def constrained_to_any_of?(*constraints)
          constraints.any? do |constraint|
            messages.any? do |message|
              message.first.first == constraint
            end
          end
        end

        private
        def messages
          @messages ||= []
        end

        def last_message
          messages.last.first.first unless messages.empty?
        end

        def record(rspec_method_name, *args, &block)
          verify_invocation_order(rspec_method_name, *args, &block)
          messages << [args.unshift(rspec_method_name), block]
          self
        end
      end

      class StubChain < Chain
        def initialize(*args, &block)
          record(:stub, *args, &block)
        end

        def invocation_order
          @invocation_order ||= {
            :stub => [nil],
            :with => [:stub],
            :and_return => [:with, :stub],
            :and_raise => [:with, :stub],
            :and_yield => [:with, :stub]
          }
        end

        def expectation_filfilled?
          true
        end

        private
        def verify_invocation_order(rspec_method_name, *args, &block)
          unless invocation_order[rspec_method_name].include?(last_message)
            raise(NoMethodError, "Undefined method #{rspec_method_name}")
          end
        end
      end

      class ExpectationChain < Chain
        def initialize(*args, &block)
          record(:should_receive, *args, &block)
          @expectation_fulfilled = false
        end

        def invocation_order
          @invocation_order ||= {
            :should_receive => [nil],
            :with => [:should_receive],
            :and_return => [:with, :should_receive],
            :and_raise => [:with, :should_receive]
          }
        end

        def expectation_fulfilled!
          @expectation_fulfilled = true
        end

        def expectation_filfilled?
          @expectation_fulfilled || constrained_to_any_of?(:never, :any_number_of_times)
        end

        private
        def verify_invocation_order(rspec_method_name, *args, &block)
        end
      end

      class Recorder
        def initialize(klass)
          @message_chains = {}
          @observed_methods = []
          @played_methods = {}
          @klass = klass
          @expectation_set = false
        end

        def stub(method_name, *args, &block)
          observe!(method_name)
          @message_chains[method_name] = StubChain.new(method_name, *args, &block)
        end

        def should_receive(method_name, *args, &block)
          observe!(method_name)
          @expectation_set = true
          @message_chains[method_name] = ExpectationChain.new(method_name, *args, &block)
        end

        def stop_all_observation!
          @observed_methods.each do |method_name|
            restore_method!(method_name)
          end
        end

        def playback!(instance, method_name)
          RSpec::Mocks::space.add(instance)
          @message_chains[method_name].playback!(instance)
          @played_methods[method_name] = instance
          received_expected_message!(method_name) if has_expectation?(method_name)
        end

        def instance_that_received(method_name)
          @played_methods[method_name]
        end

        def verify
          if @expectation_set && !each_expectation_filfilled?
            raise RSpec::Mocks::MockExpectationError, "Exactly one instance should have received the following message(s) but didn't: #{unfulfilled_expectations.sort.join(', ')}"
          end
        end

        private
        def each_expectation_filfilled?
          @message_chains.all? do |method_name, chain|
            chain.expectation_filfilled?
          end
        end

        def has_expectation?(method_name)
          @message_chains[method_name].is_a?(ExpectationChain)
        end

        def unfulfilled_expectations
          @message_chains.map do |method_name, chain|
            method_name.to_s if chain.is_a?(ExpectationChain) unless chain.expectation_filfilled?
          end.compact
        end

        def received_expected_message!(method_name)
          @message_chains[method_name].expectation_fulfilled!
          restore_method!(method_name)
          mark_invoked!(method_name)
        end

        def restore_method!(method_name)
          if @klass.method_defined?(build_alias_method_name(method_name))
            restore_original_method!(method_name)
          else
            remove_dummy_method!(method_name)
          end
        end

        def build_alias_method_name(method_name)
          "__#{method_name}_without_any_instance__"
        end

        def restore_original_method!(method_name)
          alias_method_name = build_alias_method_name(method_name)
          @klass.class_eval do
            alias_method  method_name, alias_method_name
            remove_method alias_method_name
          end
        end

        def remove_dummy_method!(method_name)
          @klass.class_eval do
            remove_method method_name
          end
        end

        def backup_method!(method_name)
          alias_method_name = build_alias_method_name(method_name)
          @klass.class_eval do
            if method_defined?(method_name)
              alias_method alias_method_name, method_name
            end
          end
        end

        def stop_observing!(method_name)
          restore_method!(method_name)
          @observed_methods.delete(method_name)
        end

        def already_observing?(method_name)
          @observed_methods.include?(method_name)
        end

        def observe!(method_name)
          stop_observing!(method_name) if already_observing?(method_name)
          @observed_methods << method_name
          backup_method!(method_name)
          @klass.class_eval(<<-EOM, __FILE__, __LINE__)
            def #{method_name}(*args, &blk)
              self.class.__recorder.playback!(self, :#{method_name})
              self.send(:#{method_name}, *args, &blk)
            end
          EOM
        end

        def mark_invoked!(method_name)
          backup_method!(method_name)
          @klass.class_eval(<<-EOM, __FILE__, __LINE__)
            def #{method_name}(*args, &blk)
              method_name = :#{method_name}
              current_instance = self
              invoked_instance = self.class.__recorder.instance_that_received(method_name)
              raise RSpec::Mocks::MockExpectationError, "The message '#{method_name}' was received by \#{self.inspect} but has already been received by \#{invoked_instance}"
            end
          EOM
        end
      end

      def any_instance
        RSpec::Mocks::space.add(self)
        __recorder
      end

      def rspec_verify
        __recorder.verify
        super
      ensure
        __recorder.stop_all_observation!
        @__recorder = nil
      end

      def __recorder
        @__recorder ||= AnyInstance::Recorder.new(self)
      end
    end
  end
end
