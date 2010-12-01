module RSpec
  module Matchers
    
    class RespondTo #:nodoc:
      def initialize(*names)
        @names = names
        @expected_arity = nil
      end
      
      def matches?(actual)
        find_failing_method_names(actual, :reject).empty?
      end

      def does_not_match?(actual)
        find_failing_method_names(actual, :select).empty?
      end
      
      def failure_message_for_should
        "expected #{@actual.inspect} to respond to #{@failing_method_names.collect {|name| name.inspect }.join(', ')}#{with_arity}"
      end
      
      def failure_message_for_should_not
        failure_message_for_should.sub(/to respond to/, 'not to respond to')
      end
      
      def description
        "respond to #{pp_names}#{with_arity}"
      end
      
      def with(n)
        @expected_arity = n
        self
      end
      
      def argument
        self
      end
      alias :arguments :argument
      
    private

      def find_failing_method_names(actual, filter_method)
        @actual = actual
        @failing_method_names = @names.send(filter_method) do |name|
          @actual.respond_to?(name) && matches_arity?(actual, name)
        end
      end
      
      def matches_arity?(actual, name)
        return true unless @expected_arity

        actual_arity = actual.method(name).arity
        if actual_arity < 0
          # ~ inverts the one's complement and gives us the number of required args
          ~actual_arity <= @expected_arity
        else
          actual_arity == @expected_arity
        end
      end
      
      def with_arity
        @expected_arity.nil?? "" :
          " with #{@expected_arity} argument#{@expected_arity == 1 ? '' : 's'}"
      end
      
      def pp_names
        # Ruby 1.9 returns the same thing for array.to_s as array.inspect, so just use array.inspect here
        @names.length == 1 ? "##{@names.first}" : @names.inspect
      end
    end
    
    # :call-seq:
    #   should respond_to(*names)
    #   should_not respond_to(*names)
    #
    # Matches if the target object responds to all of the names
    # provided. Names can be Strings or Symbols.
    #
    # == Examples
    # 
    def respond_to(*names)
      Matchers::RespondTo.new(*names)
    end
  end
end
