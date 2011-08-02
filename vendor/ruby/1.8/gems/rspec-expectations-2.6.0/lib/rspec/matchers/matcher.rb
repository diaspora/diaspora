module RSpec
  module Matchers
    class Matcher
      include RSpec::Matchers::InstanceExec
      include RSpec::Matchers::Pretty
      include RSpec::Matchers

      attr_reader :expected, :actual, :rescued_exception
      def initialize(name, *expected, &declarations)
        @name     = name
        @expected = expected
        @actual   = nil
        @diffable = false
        @expected_exception, @rescued_exception = nil, nil
        @match_for_should_not_block = nil

        @messages = {
          :description => lambda {"#{name_to_sentence}#{expected_to_sentence}"},
          :failure_message_for_should => lambda {|actual| "expected #{actual.inspect} to #{name_to_sentence}#{expected_to_sentence}"},
          :failure_message_for_should_not => lambda {|actual| "expected #{actual.inspect} not to #{name_to_sentence}#{expected_to_sentence}"}
        }
        making_declared_methods_public do
          instance_exec(*@expected, &declarations)
        end
      end
      
      #Used internally by +should+ and +should_not+.
      def matches?(actual)
        @actual = actual
        if @expected_exception
          begin
            instance_exec(actual, &@match_block)
            true
          rescue @expected_exception => @rescued_exception
            false
          end
        else
          begin
            instance_exec(actual, &@match_block)
          rescue RSpec::Expectations::ExpectationNotMetError
            false
          end
        end
      end

      # Used internally by +should_not+
      def does_not_match?(actual)
        @actual = actual
        @match_for_should_not_block ?
          instance_exec(actual, &@match_for_should_not_block) :
          !matches?(actual)
      end

      def include(*args)
        singleton_class.__send__(:include, *args)
      end

      def define_method(name, &block) # :nodoc:
        singleton_class.__send__(:define_method, name, &block)
      end

      # See RSpec::Matchers
      def match(&block)
        @match_block = block
      end
      alias match_for_should match

      # See RSpec::Matchers
      def match_for_should_not(&block)
        @match_for_should_not_block = block
      end

      # See RSpec::Matchers
      def match_unless_raises(exception=Exception, &block)
        @expected_exception = exception
        match(&block)
      end

      # See RSpec::Matchers
      def failure_message_for_should(&block)
        cache_or_call_cached(:failure_message_for_should, &block)
      end

      # See RSpec::Matchers
      def failure_message_for_should_not(&block)
        cache_or_call_cached(:failure_message_for_should_not, &block)
      end

      # See RSpec::Matchers
      def description(&block)
        cache_or_call_cached(:description, &block)
      end

      #Used internally by objects returns by +should+ and +should_not+.
      def diffable?
        @diffable
      end

      # See RSpec::Matchers
      def diffable
        @diffable = true
      end
      
      # See RSpec::Matchers
      def chain(method, &block)
        define_method method do |*args|
          block.call(*args)
          self
        end
      end
      
    private

      def method_missing(method, *args, &block)
        if $matcher_execution_context.respond_to?(method)
          $matcher_execution_context.send method, *args, &block
        else
          super(method, *args, &block)
        end
      end
    
      def making_declared_methods_public # :nodoc:
        # Our home-grown instance_exec in ruby 1.8.6 results in any methods
        # declared in the block eval'd by instance_exec in the block to which we
        # are yielding here are scoped private. This is NOT the case for Ruby
        # 1.8.7 or 1.9.
        #
        # Also, due some crazy scoping that I don't understand, these methods
        # are actually available in the specs (something about the matcher being
        # defined in the scope of RSpec::Matchers or within an example), so not
        # doing the following will not cause specs to fail, but they *will*
        # cause features to fail and that will make users unhappy. So don't.
        orig_private_methods = private_methods
        yield
        (private_methods - orig_private_methods).each {|m| singleton_class.__send__ :public, m}
      end

      def cache_or_call_cached(key, &block)
        block ? cache(key, &block) : call_cached(key)
      end

      def cache(key, &block)
        @messages[key] = block
      end

      def call_cached(key)
        @messages[key].arity == 1 ? @messages[key].call(@actual) : @messages[key].call
      end

      def name_to_sentence
        split_words(@name)
      end

      def expected_to_sentence
        to_sentence(@expected)
      end

      unless method_defined?(:singleton_class)
        def singleton_class
          class << self; self; end
        end
      end
    end
  end
end
