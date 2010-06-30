require 'em-websocket'
require 'eventmachine'
require 'lib/socket_render'
module WebSocket
  EM.next_tick {
    EM.add_timer(0.1) do
      @channel = EM::Channel.new
      puts @channel.inspect
      include SocketRenderer
      
      SocketRenderer.instantiate_view 
    end
    
    EventMachine::WebSocket.start(
                  :host => "0.0.0.0", 
                  :port => APP_CONFIG[:socket_port],
                  :debug =>APP_CONFIG[:debug]) do |ws|
      ws.onopen {
        sid = @channel.subscribe { |msg| ws.send msg }
        
        ws.onmessage { |msg| }#@channel.push msg; puts msg}

        ws.onclose {  @channel.unsubscribe(sid) }
      }
    end
  }

  def self.update_clients(object)
    @channel.push(SocketRenderer.view_hash(object).to_json) if @channel
  end
end
