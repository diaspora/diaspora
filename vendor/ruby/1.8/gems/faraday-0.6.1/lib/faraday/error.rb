module Faraday
  module Error
    class ClientError < StandardError
      attr_reader :response

      def initialize(ex)
        @wrapped_exception = nil
        @response = nil

        if ex.respond_to?(:backtrace)
          super(ex.message)
          @wrapped_exception = ex
        elsif ex.respond_to?(:each_key)
          super("the server responded with status #{ex[:status]}")
          @response = ex
        else
          super(ex.to_s)
        end
      end

      def backtrace
        if @wrapped_exception
          @wrapped_exception.backtrace
        else
          super
        end
      end

      def inspect
        %(#<#{self.class}>)
      end
    end

    class ConnectionFailed < ClientError;   end
    class ResourceNotFound < ClientError;   end
    class ParsingError     < ClientError;   end
  end
end
