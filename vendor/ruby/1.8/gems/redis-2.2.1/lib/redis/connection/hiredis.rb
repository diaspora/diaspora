require "redis/connection/registry"
require "hiredis/connection"
require "timeout"

class Redis
  module Connection
    class Hiredis
      def initialize
        @connection = ::Hiredis::Connection.new
      end

      def connected?
        @connection.connected?
      end

      def timeout=(usecs)
        @connection.timeout = usecs
      end

      def connect(host, port, timeout)
        @connection.connect(host, port, timeout)
      rescue Errno::ETIMEDOUT
        raise Timeout::Error
      end

      def connect_unix(path, timeout)
        @connection.connect_unix(path, timeout)
      rescue Errno::ETIMEDOUT
        raise Timeout::Error
      end

      def disconnect
        @connection.disconnect
      end

      def write(command)
        @connection.write(command)
      end

      def read
        @connection.read
      rescue RuntimeError => err
        raise ::Redis::ProtocolError.new(err.message)
      end
    end
  end
end

Redis::Connection.drivers << Redis::Connection::Hiredis
