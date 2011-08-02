module RSpec
  module Mocks
    class ErrorGenerator
      attr_writer :opts
      
      def initialize(target, name, options={})
        @declared_as = options[:__declared_as] || 'Mock'
        @target = target
        @name = name
      end
      
      def opts
        @opts ||= {}
      end

      def raise_unexpected_message_error(sym, *args)
        __raise "#{intro} received unexpected message :#{sym}#{arg_message(*args)}"
      end
      
      def raise_unexpected_message_args_error(expectation, *args)
        expected_args = format_args(*expectation.expected_args)
        actual_args = format_args(*args)
        __raise "#{intro} received #{expectation.sym.inspect} with unexpected arguments\n  expected: #{expected_args}\n       got: #{actual_args}"
      end
      
      def raise_similar_message_args_error(expectation, *args)
        expected_args = format_args(*expectation.expected_args)
        actual_args = args.collect {|a| format_args(*a)}.join(", ")
        __raise "#{intro} received #{expectation.sym.inspect} with unexpected arguments\n  expected: #{expected_args}\n       got: #{actual_args}"
      end
      
      def raise_expectation_error(sym, expected_received_count, actual_received_count, *args)
        __raise "(#{intro}).#{sym}#{format_args(*args)}\n    expected: #{count_message(expected_received_count)}\n    received: #{count_message(actual_received_count)}"
      end
      
      def raise_out_of_order_error(sym)
        __raise "#{intro} received :#{sym} out of order"
      end
      
      def raise_block_failed_error(sym, detail)
        __raise "#{intro} received :#{sym} but passed block failed with: #{detail}"
      end
      
      def raise_missing_block_error(args_to_yield)
        __raise "#{intro} asked to yield |#{arg_list(*args_to_yield)}| but no block was passed"
      end
      
      def raise_wrong_arity_error(args_to_yield, arity)
        __raise "#{intro} yielded |#{arg_list(*args_to_yield)}| to block with arity of #{arity}"
      end
      
    private

      def intro
        if @name
          "#{@declared_as} #{@name.inspect}"
        elsif Mock === @target
          @declared_as
        elsif Class === @target
          "<#{@target.inspect} (class)>"
        elsif @target
          @target
        else
          "nil"
        end
      end
      
      def __raise(message)
        message = opts[:message] unless opts[:message].nil?
        Kernel::raise(RSpec::Mocks::MockExpectationError, message)
      end
      
      def arg_message(*args)
        " with " + format_args(*args)
      end
      
      def format_args(*args)
        args.empty? ? "(no args)" : "(" + arg_list(*args) + ")"
      end

      def arg_list(*args)
        args.collect {|arg| arg.respond_to?(:description) ? arg.description : arg.inspect}.join(", ")
      end
      
      def count_message(count)
        return "at least #{pretty_print(count.abs)}" if count < 0
        return pretty_print(count)
      end

      def pretty_print(count)
        "#{count} time#{count == 1 ? '' : 's'}"
      end

    end
  end
end

