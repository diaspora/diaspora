require 'em-websocket'
require 'eventmachine'



module WebSocket
  EM.next_tick {
    initialize_channel
    
    EventMachine::WebSocket.start(
                  :host => "0.0.0.0", 
                  :port => APP_CONFIG[:socket_port],
                  :debug =>APP_CONFIG[:debug]) do |ws|
      ws.onopen {
        @ws = ws
        sid = @channel.subscribe{ |msg| ws.send msg }#SocketsController.new.new_subscriber
        
        ws.onmessage { |msg| SocketsController.new.incoming(msg) }#@channel.push msg; puts msg}

        ws.onclose { SocketsController.new.delete_subscriber(sid) }
      }
    end
  }

  def self.initialize_channel
    @channel = EM::Channel.new
  end
  
  def self.push_to_clients(html)
    @channel.push(html)
  end
  
  def self.unsubscribe(sid)
    @channel.unsubscribe(sid)
  end
  
  
  def self.subscribe
    @channel.subscribe{ |msg| ws.send msg }
  end
  
end

