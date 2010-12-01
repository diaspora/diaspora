module RSpec
  module Core
    module Pending
      DEFAULT_MESSAGE = 'No reason given'

      def pending(*args)
        options = args.last.is_a?(Hash) ? args.pop : {}
        message = args.first || DEFAULT_MESSAGE

        if options[:unless] || (options.has_key?(:if) && !options[:if])
          return block_given? ? yield : nil
        end

        example.metadata[:pending] = true
        example.metadata[:execution_result][:pending_message] = message
        if block_given?
          begin
            result = yield
            example.metadata[:pending] = false
          rescue Exception => e
          end
          raise RSpec::Core::PendingExampleFixedError.new if result
        end
        throw :pending_declared_in_example, message
      end
    end
  end
end
