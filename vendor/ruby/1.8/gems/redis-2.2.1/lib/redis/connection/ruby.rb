require "redis/connection/registry"
require "redis/connection/command_helper"
require "socket"

class Redis
  module Connection
    class Ruby
      include Redis::Connection::CommandHelper

      MINUS    = "-".freeze
      PLUS     = "+".freeze
      COLON    = ":".freeze
      DOLLAR   = "$".freeze
      ASTERISK = "*".freeze

      def initialize
        @sock = nil
      end

      def connected?
        !! @sock
      end

      def connect(host, port, timeout)
        with_timeout(timeout.to_f / 1_000_000) do
          @sock = TCPSocket.new(host, port)
          @sock.setsockopt Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1
        end
      end

      def connect_unix(path, timeout)
        with_timeout(timeout.to_f / 1_000_000) do
          @sock = UNIXSocket.new(path)
        end
      end

      def disconnect
        @sock.close
      rescue
      ensure
        @sock = nil
      end

      def timeout=(usecs)
        secs   = Integer(usecs / 1_000_000)
        usecs  = Integer(usecs - (secs * 1_000_000)) # 0 - 999_999

        optval = [secs, usecs].pack("l_2")

        begin
          @sock.setsockopt Socket::SOL_SOCKET, Socket::SO_RCVTIMEO, optval
          @sock.setsockopt Socket::SOL_SOCKET, Socket::SO_SNDTIMEO, optval
        rescue Errno::ENOPROTOOPT
        end
      end

      def write(command)
        @sock.write(build_command(command))
      end

      def read
        # We read the first byte using read() mainly because gets() is
        # immune to raw socket timeouts.
        reply_type = @sock.read(1)

        raise Errno::ECONNRESET unless reply_type

        format_reply(reply_type, @sock.gets)
      end

      def format_reply(reply_type, line)
        case reply_type
        when MINUS    then format_error_reply(line)
        when PLUS     then format_status_reply(line)
        when COLON    then format_integer_reply(line)
        when DOLLAR   then format_bulk_reply(line)
        when ASTERISK then format_multi_bulk_reply(line)
        else raise ProtocolError.new(reply_type)
        end
      end

      def format_error_reply(line)
        RuntimeError.new(line.strip)
      end

      def format_status_reply(line)
        line.strip
      end

      def format_integer_reply(line)
        line.to_i
      end

      def format_bulk_reply(line)
        bulklen = line.to_i
        return if bulklen == -1
        reply = encode(@sock.read(bulklen))
        @sock.read(2) # Discard CRLF.
        reply
      end

      def format_multi_bulk_reply(line)
        n = line.to_i
        return if n == -1

        Array.new(n) { read }
      end

    protected

      begin
        require "system_timer"

        def with_timeout(seconds, &block)
          SystemTimer.timeout_after(seconds, &block)
        end

      rescue LoadError
        if ! defined?(RUBY_ENGINE)
          # MRI 1.8, all other interpreters define RUBY_ENGINE, JRuby and
          # Rubinius should have no issues with timeout.
          warn "WARNING: using the built-in Timeout class which is known to have issues when used for opening connections. Install the SystemTimer gem if you want to make sure the Redis client will not hang."
        end

        require "timeout"

        def with_timeout(seconds, &block)
          Timeout.timeout(seconds, &block)
        end
      end
    end
  end
end

Redis::Connection.drivers << Redis::Connection::Ruby
