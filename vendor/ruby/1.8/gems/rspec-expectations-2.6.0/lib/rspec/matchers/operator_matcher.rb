module RSpec
  module Matchers

    class OperatorMatcher
      class << self
        def registry
          @registry ||= {}
        end

        def register(klass, operator, matcher)
          registry[klass] ||= {}
          registry[klass][operator] = matcher
        end

        def get(klass, operator)
          registry[klass] && registry[klass][operator]
        end
      end

      def initialize(actual)
        @actual = actual
      end

      def self.use_custom_matcher_or_delegate(operator)
        define_method(operator) do |expected|
          if matcher = OperatorMatcher.get(@actual.class, operator)
            @actual.send(::RSpec::Matchers.last_should, matcher.new(expected))
          else
            eval_match(@actual, operator, expected)
          end
        end

        negative_operator = operator.sub(/^=/, '!')
        if negative_operator != operator && respond_to?(negative_operator)
          define_method(negative_operator) do |expected|
            opposite_should = ::RSpec::Matchers.last_should == :should ? :should_not : :should
            raise "RSpec does not support `#{::RSpec::Matchers.last_should} #{negative_operator} expected`.  " +
                  "Use `#{opposite_should} #{operator} expected` instead."
          end
        end
      end

      ['==', '===', '=~', '>', '>=', '<', '<='].each do |operator|
        use_custom_matcher_or_delegate operator
      end

      def fail_with_message(message)
        RSpec::Expectations.fail_with(message, @expected, @actual)
      end

      def description
        "#{@operator} #{@expected.inspect}"
      end
      
    private
      
      def eval_match(actual, operator, expected)
        ::RSpec::Matchers.last_matcher = self
        @operator, @expected = operator, expected
        __delegate_operator(actual, operator, expected)
      end

    end

    class PositiveOperatorMatcher < OperatorMatcher #:nodoc:
      def __delegate_operator(actual, operator, expected)
        if actual.__send__(operator, expected)
          true
        elsif ['==','===', '=~'].include?(operator)
          fail_with_message("expected: #{expected.inspect}\n     got: #{actual.inspect} (using #{operator})") 
        else
          fail_with_message("expected: #{operator} #{expected.inspect}\n     got: #{operator.gsub(/./, ' ')} #{actual.inspect}")
        end
      end

    end

    class NegativeOperatorMatcher < OperatorMatcher #:nodoc:
      def __delegate_operator(actual, operator, expected)
        return false unless actual.__send__(operator, expected)
        return fail_with_message("expected not: #{operator} #{expected.inspect}\n         got: #{operator.gsub(/./, ' ')} #{actual.inspect}")
      end

    end

  end
end
