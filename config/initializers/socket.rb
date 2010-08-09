require 'em-websocket'
require 'eventmachine'

module WebSocket
  EM.next_tick {
    initialize_channels
    
    EventMachine::WebSocket.start(
                  :host => "0.0.0.0", 
                  :port => APP_CONFIG[:socket_port],
                  :debug =>APP_CONFIG[:debug]) do |ws|
      ws.onopen {
        
        sid = self.subscribe(ws.request['Path'].gsub('/',''), ws)
        
        ws.onmessage { |msg| SocketsController.new.incoming(msg) }#@channel.push msg; puts msg}

        ws.onclose { unsubscribe(ws.request['Path'].gsub('/',''), sid) }
      }
    end
  }

  def self.initialize_channels
    @channels = {} 
  end
  
  def self.push_to_user(uid, data)
    puts "Pushing to #{uid}"
    @channels[uid.to_s].push(data) if @channels[uid.to_s]
  end
  
  def self.subscribe(uid, ws)
    puts "Subscribing #{uid}"
    @channels[uid] ||= EM::Channel.new
    @channels[uid].subscribe{ |msg| ws.send msg }
  end

  def self.unsubscribe(uid,sid)
    @channels[uid].unsubscribe(sid) if @channels[uid]
  end
  
end

