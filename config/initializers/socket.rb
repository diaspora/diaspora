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
        sid = SocketController.new.new_subscriber(ws)
        
        ws.onmessage { |msg| SocketController.new.incoming(msg) }#@channel.push msg; puts msg}

        ws.onclose { SocketController.new.delete_subscriber(sid) }
      }
    end
  }

  def self.initialize_channel
    @channel = EM::Channel.new
    puts @channel.inspect
  end
  
  def self.push_to_clients(html)
    @channel.push(html)
  end
  
  def self.unsubscribe(sid)
    @channel.unsubscribe(sid)
  end
  
  
  def self.subscribe
    @channel.subscribe{ |msg| puts "hello #{msg}";@ws.send msg }
  end
  
end

