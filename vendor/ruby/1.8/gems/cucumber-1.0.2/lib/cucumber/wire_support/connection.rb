require 'timeout'
require 'cucumber/wire_support/wire_protocol'

module Cucumber
  module WireSupport
    class Connection
      class ConnectionError < StandardError; end
        
      include WireProtocol
      
      def initialize(config)
        @config = config
      end
      
      def call_remote(request_handler, message, params)
        packet = WirePacket.new(message, params)

        begin
          send_data_to_socket(packet.to_json)
          response = fetch_data_from_socket(@config.timeout(message))
          response.handle_with(request_handler)
        rescue Timeout::Error => e
          backtrace = e.backtrace ; backtrace.shift # because Timeout puts some wierd stuff in there
          raise Timeout::Error, "Timed out calling wire server with message '#{message}'", backtrace
        end
      end
      
      def exception(params)
        WireException.new(params, @config.host, @config.port)
      end

      private
      
      def send_data_to_socket(data)
        Timeout.timeout(@config.timeout) { socket.puts(data) }
      end

      def fetch_data_from_socket(timeout)
        raw_response = 
          if timeout == :never
            socket.gets
          else
            Timeout.timeout(timeout) { socket.gets }
          end
        WirePacket.parse(raw_response)
      end
      
      def socket
        @socket ||= TCPSocket.new(@config.host, @config.port)
      rescue Errno::ECONNREFUSED => exception
        raise(ConnectionError, "Unable to contact the wire server at #{@config.host}:#{@config.port}. Is it up?")
      end
    end
  end
end