require 'socket'
require 'json'

class FakeWireServer
  def initialize(port, protocol_table)
    @port, @protocol_table = port, protocol_table
    @delays = {}
  end

  def run
    @server = TCPServer.open(@port)
    loop { handle_connections }
  end
  
  def delay_response(message, delay)
    @delays[message] = delay
  end

  private

  def handle_connections
    Thread.start(@server.accept) { |socket| open_session_on socket }
  end

  def open_session_on(socket)
    begin
      SocketSession.new(socket, @protocol_table, @delays).start
    rescue Exception => e
      raise e
    ensure
      socket.close
    end
  end
  
  class SocketSession
    def initialize(socket, protocol, delays)
      @socket = socket
      @protocol = protocol
      @delays = delays
    end

    def start
      while message = @socket.gets
        handle(message)
      end
    end

    private
    
    def handle(data)
      if protocol_entry = response_to(data.strip)
        sleep delay(data)
        send_response(protocol_entry['response'])
      else
        serialized_exception = { :message => "Not understood: #{data}", :backtrace => [] }
        send_response(['fail', serialized_exception ].to_json)
      end
    rescue => e
      send_response(['fail', { :message => e.message, :backtrace => e.backtrace, :exception => e.class } ].to_json)
    end

    def response_to(data)
      @protocol.detect do |entry| 
        JSON.parse(entry['request']) == JSON.parse(data)
      end
    end

    def send_response(response)
      @socket.puts response + "\n"
    end
    
    def delay(data)
      message = JSON.parse(data.strip)[0]
      @delays[message.to_sym] || 0
    end
  end
end