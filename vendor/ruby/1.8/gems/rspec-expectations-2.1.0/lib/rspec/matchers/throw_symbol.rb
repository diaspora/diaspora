module RSpec
  module Matchers
    
    class ThrowSymbol #:nodoc:
      def initialize(expected_symbol = nil, expected_arg=nil)
        @expected_symbol = expected_symbol
        @expected_arg = expected_arg
        @caught_symbol = @caught_arg = nil
      end
      
      def matches?(given_proc)
        begin
          if @expected_symbol.nil?
            given_proc.call
          else
            @caught_arg = catch :proc_did_not_throw_anything do
              catch @expected_symbol do
                given_proc.call
                throw :proc_did_not_throw_anything, :nothing_thrown
              end
            end

            if @caught_arg == :nothing_thrown
              @caught_arg = nil
            else
              @caught_symbol = @expected_symbol
            end
          end

        # Ruby 1.8 uses NameError with `symbol'
        # Ruby 1.9 uses ArgumentError with :symbol
        rescue NameError, ArgumentError => e
          unless e.message =~ /uncaught throw (`|\:)([a-zA-Z0-9_]*)(')?/
            other_exception = e
            raise
          end
          @caught_symbol = $2.to_sym
        rescue => other_exception
          raise
        ensure
          unless other_exception
            if @expected_symbol.nil?
              return !@caught_symbol.nil?
            else
              if @expected_arg.nil?
                return @caught_symbol == @expected_symbol
              else
                return (@caught_symbol == @expected_symbol) & (@caught_arg == @expected_arg)
              end
            end
          end
        end
      end

      def failure_message_for_should
        "expected #{expected} to be thrown, got #{caught}"
      end
      
      def failure_message_for_should_not
        "expected #{expected('no Symbol')}#{' not' if @expected_symbol} to be thrown, got #{caught}"
      end
      
      def description
        "throw #{expected}"
      end
      
      private

        def expected(symbol_desc = 'a Symbol')
          throw_description(@expected_symbol || symbol_desc, @expected_arg)
        end

        def caught
          throw_description(@caught_symbol || 'nothing', @caught_arg)
        end

        def throw_description(symbol, arg)
          symbol_description = symbol.is_a?(String) ? symbol : symbol.inspect

          arg_description = if arg
            " with #{arg.inspect}"
          elsif @expected_arg && @caught_symbol == @expected_symbol
            " with no argument"
          else
            ""
          end

          symbol_description + arg_description
        end

    end
 
    # :call-seq:
    #   should throw_symbol()
    #   should throw_symbol(:sym)
    #   should throw_symbol(:sym, arg)
    #   should_not throw_symbol()
    #   should_not throw_symbol(:sym)
    #   should_not throw_symbol(:sym, arg)
    #
    # Given no argument, matches if a proc throws any Symbol.
    #
    # Given a Symbol, matches if the given proc throws the specified Symbol.
    #
    # Given a Symbol and an arg, matches if the given proc throws the
    # specified Symbol with the specified arg.
    #
    # == Examples
    #
    #   lambda { do_something_risky }.should throw_symbol
    #   lambda { do_something_risky }.should throw_symbol(:that_was_risky)
    #   lambda { do_something_risky }.should throw_symbol(:that_was_risky, culprit)
    #
    #   lambda { do_something_risky }.should_not throw_symbol
    #   lambda { do_something_risky }.should_not throw_symbol(:that_was_risky)
    #   lambda { do_something_risky }.should_not throw_symbol(:that_was_risky, culprit)
    def throw_symbol(expected_symbol = nil, expected_arg=nil)
      Matchers::ThrowSymbol.new(expected_symbol, expected_arg)
    end
  end
end
