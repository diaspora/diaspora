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
    puts @channels.size
    Rails.logger.info "Pushing to #{uid}"
    @channels[uid.to_s][0].push(data) if @channels[uid.to_s]
  end
  
  def self.subscribe(uid, ws)
    puts "Subscribing socket to #{User.first(:id => uid).email}"
    self.ensure_channel(uid)
    @channels[uid][0].subscribe{ |msg| ws.send msg }
    @channels[uid][1] += 1
  end

  def self.ensure_channel(uid)
    @channels[uid] ||= [EM::Channel.new, 0 ]
  end

  def self.unsubscribe(uid,sid)
    puts "Unsubscribing socket #{sid} from #{User.first(:id => uid).email}"
    @channels[uid][0].unsubscribe(sid) if @channels[uid]
    @channels[uid][1] -= 1
    if @channels[uid][1] <= 0
      @channels[uid] = nil
    end
  end
  
end

