require 'em-websocket'
require 'eventmachine'

module WebSocket
  EM.next_tick {
    EM.add_timer(0.1) do
      @channel = EM::Channel.new
      @view = ActionView::Base.new(ActionController::Base.view_paths, {})  
      class << @view  
        include ApplicationHelper 
        include Rails.application.routes.url_helpers
      end
    end
    
    EventMachine::WebSocket.start(:host => "0.0.0.0", :port => 8080, :debug => true) do |ws|
      ws.onopen {
        sid = @channel.subscribe { |msg| ws.send msg }
        
        ws.onmessage { |msg|
          @channel.push msg
        }

        ws.onclose {
          @channel.unsubscribe(sid)
        }

      }
    end
  }
  #this should get folded into message queue i think?
  def self.update_clients(object)

      n = @view.render(:partial => @view.type_partial(object), :locals => {:post  => object})  
      @channel.push(n) if @channel
  end

end
