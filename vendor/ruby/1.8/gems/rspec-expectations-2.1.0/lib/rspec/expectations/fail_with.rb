module RSpec
  module Expectations
    class << self
      def differ
        @differ ||= Differ.new
      end
      
      # raises a RSpec::Expectations::ExpectationNotMetError with message
      #
      # When a differ has been assigned and fail_with is passed
      # <code>expected</code> and <code>actual</code>, passes them
      # to the differ to append a diff message to the failure message.
      def fail_with(message, expected=nil, actual=nil) # :nodoc:
        if !message
          raise ArgumentError, "Failure message is nil. Does your matcher define the " +
                               "appropriate failure_message_for_* method to return a string?"
        end

        if actual && expected
          if all_strings?(actual, expected)
            if any_multiline_strings?(actual, expected)
              message << "\nDiff:" << self.differ.diff_as_string(actual, expected)
            end
          elsif no_procs?(actual, expected) && no_numbers?(actual, expected)
            message << "\nDiff:" << self.differ.diff_as_object(actual, expected)
          end
        end

        raise(RSpec::Expectations::ExpectationNotMetError.new(message))
      end

    private

      def no_procs?(*args)
        args.none? {|a| Proc === a}
      end

      def all_strings?(*args)
        args.all? {|a| String === a}
      end

      def any_multiline_strings?(*args)
        all_strings?(*args) && args.any? {|a| a =~ /\n/}
      end

      def no_numbers?(*args)
        args.none? {|a| Numeric === a}
      end
    end
  end
end
