require 'em-websocket'
require 'eventmachine'

module WebSocket
  
  #mattr_accessor :channel

  EM.next_tick {
    EM.add_timer(0.1) do
      #puts "channel set"
      @channel = EM::Channel.new
    end
    
    EventMachine::WebSocket.start(:host => "0.0.0.0", :port => 8080, :debug => true) do |ws|
      ws.onopen {
        sid = @channel.subscribe { |msg| ws.send msg }
        #@channel.push "#{sid} connectdfged!"
        puts @channel.inspect

        ws.onmessage { |msg|
          @channel.push "#{msg}"
        }

        ws.onclose {
          @channel.unsubscribe(sid)
        }

      }
    end
}
  #this should get folded into message queue i think?
  def self.update_clients(json)
    #EM.add_timer(5) do
      #puts @channel
      @channel.push json
    #end
  end

end
