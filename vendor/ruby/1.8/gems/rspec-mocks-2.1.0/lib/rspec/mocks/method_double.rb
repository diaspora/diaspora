module RSpec
  module Mocks
    class MethodDouble < Hash
      attr_reader :method_name

      def initialize(object, method_name, proxy)
        @method_name = method_name
        @object = object
        @proxy = proxy
        @stashed = false
        store(:expectations, [])
        store(:stubs, [])
      end

      def expectations
        self[:expectations]
      end

      def stubs
        self[:stubs]
      end

      def visibility
        if Mock === @object
          'public'
        elsif object_singleton_class.private_method_defined?(@method_name)
          'private'
        elsif object_singleton_class.protected_method_defined?(@method_name)
          'protected'
        else
          'public'
        end
      end

      def object_singleton_class
        class << @object; self; end
      end

      def obfuscate(method_name)
        "obfuscated_by_rspec_mocks__#{method_name}"
      end

      def stashed_method_name
        obfuscate(method_name)
      end

      def object_responds_to?(method_name)
        if @proxy.already_proxied_respond_to?
          @object.__send__(obfuscate(:respond_to?), method_name)
        elsif method_name == :respond_to?
          @proxy.already_proxied_respond_to
        else
          @object.respond_to?(method_name, true)
        end
      end

      def configure_method
        RSpec::Mocks::space.add(@object) if RSpec::Mocks::space
        warn_if_nil_class
        unless @stashed
          stash_original_method
          define_proxy_method
        end
      end

      def stash_original_method
        stashed = stashed_method_name
        orig = @method_name
        object_singleton_class.class_eval do
          alias_method(stashed, orig) if method_defined?(orig) || private_method_defined?(orig)
        end
        @stashed = true
      end

      def define_proxy_method
        method_name = @method_name
        visibility_for_method = "#{visibility} :#{method_name}"
        object_singleton_class.class_eval(<<-EOF, __FILE__, __LINE__)
          def #{method_name}(*args, &block)
            __mock_proxy.message_received :#{method_name}, *args, &block
          end
          #{visibility_for_method}
        EOF
      end

      def restore_original_method
        if @stashed
          method_name = @method_name
          stashed_method_name = self.stashed_method_name
          object_singleton_class.instance_eval do
            remove_method method_name
            if method_defined?(stashed_method_name) || private_method_defined?(stashed_method_name)
              alias_method method_name, stashed_method_name
              remove_method stashed_method_name
            end
          end
          @stashed = false
        end
      end

      def verify
        expectations.each {|e| e.verify_messages_received}
      end

      def reset
        reset_nil_expectations_warning
        restore_original_method
        clear
      end

      def clear
        expectations.clear
        stubs.clear
      end

      def add_expectation(error_generator, expectation_ordering, expected_from, opts, &block)
        configure_method
        expectation = if existing_stub = stubs.first
          existing_stub.build_child(expected_from, block, 1, opts)
        else
          MessageExpectation.new(error_generator, expectation_ordering, expected_from, @method_name, block, 1, opts)
        end
        expectations << expectation
        expectation
      end

      def add_negative_expectation(error_generator, expectation_ordering, expected_from, &implementation)
        configure_method
        expectation = NegativeMessageExpectation.new(error_generator, expectation_ordering, expected_from, @method_name, implementation)
        expectations.unshift expectation
        expectation
      end

      def add_stub(error_generator, expectation_ordering, expected_from, opts={}, &implementation)
        configure_method
        stub = MessageExpectation.new(error_generator, expectation_ordering, expected_from, @method_name, nil, :any, opts, &implementation)
        stubs.unshift stub
        stub
      end
      
      def remove_stub
        raise_method_not_stubbed_error if stubs.empty?
        expectations.empty? ? reset : stubs.clear
      end

      def proxy_for_nil_class?
        @object.nil?
      end

      def warn_if_nil_class
        if proxy_for_nil_class? & RSpec::Mocks::Proxy.warn_about_expectations_on_nil
          Kernel.warn("An expectation of :#{@method_name} was set on nil. Called from #{caller[4]}. Use allow_message_expectations_on_nil to disable warnings.")
        end
      end
      
      def raise_method_not_stubbed_error
        raise MockExpectationError, "The method `#{method_name}` was not stubbed or was already unstubbed" 
      end

      def reset_nil_expectations_warning
        RSpec::Mocks::Proxy.warn_about_expectations_on_nil = true if proxy_for_nil_class?
      end
    end
  end
end
