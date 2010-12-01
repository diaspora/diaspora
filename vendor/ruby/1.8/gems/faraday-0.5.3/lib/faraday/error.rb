module Faraday
  module Error
    class ClientError < StandardError
      def initialize(exception)
        @inner_exception = exception
      end

      def message
        @inner_exception.message
      end

      def backtrace
        @inner_exception.backtrace
      end

      alias to_str message

      def to_s
        @inner_exception.to_s
      end

      def inspect
        @inner_exception.inspect
      end
    end

    class ConnectionFailed < ClientError;   end
    class ResourceNotFound < ClientError;   end
    class ParsingError     < ClientError;   end
  end
end
