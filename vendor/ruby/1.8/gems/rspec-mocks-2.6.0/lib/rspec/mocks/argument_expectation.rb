module RSpec
  module Mocks
    class ArgumentExpectation
      attr_reader :args
      
      def initialize(*args, &block)
        @args = args
        @block = args.empty? ? block : nil
        @match_any_args = false
        @matchers = nil
        
        case args.first
        when ArgumentMatchers::AnyArgsMatcher
          @match_any_args = true
        when ArgumentMatchers::NoArgsMatcher
          @matchers = []
        else
          @matchers = args.collect {|arg| matcher_for(arg)}
        end
      end
      
      def matcher_for(arg)
        return ArgumentMatchers::MatcherMatcher.new(arg) if is_matcher?(arg)
        return ArgumentMatchers::RegexpMatcher.new(arg)  if arg.is_a?(Regexp)
        return ArgumentMatchers::EqualityProxy.new(arg)
      end
      
      def is_matcher?(obj)
        !null_object?(obj) & obj.respond_to?(:matches?) & obj.respond_to?(:description)
      end

      def args_match?(*args)
        match_any_args? || block_passes?(*args) || matchers_match?(*args)
      end
      
      private
      def null_object?(obj)
        obj.respond_to?(:__rspec_double_acting_as_null_object?) && obj.__rspec_double_acting_as_null_object?
      end
      
      def block_passes?(*args)
        @block.call(*args) if @block
      end
      
      def matchers_match?(*args)
        @matchers == args
      end
      
      def match_any_args?
        @match_any_args
      end
    end
  end
end
