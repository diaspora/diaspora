require 'em-websocket'
require 'eventmachine'

module WebSocket
  EM.next_tick {
    EM.add_timer(0.1) do
      @channel = EM::Channel.new
      puts @channel.inspect
      @view = ActionView::Base.new(ActionController::Base.view_paths, {})  
      
      class << @view  
        include ApplicationHelper 
        include Rails.application.routes.url_helpers
        include ActionController::RequestForgeryProtection::ClassMethods
        include ActionView::Helpers::FormTagHelper
        include ActionView::Helpers::UrlHelper
        def protect_against_forgery?
          false
        end
      end
    end
    
    EventMachine::WebSocket.start(:host => "0.0.0.0", :port => 8080, :debug =>true) do |ws|
      ws.onopen {
        sid = @channel.subscribe { |msg| ws.send msg }
        
        ws.onmessage { |msg| }#@channel.push msg; puts msg}

        ws.onclose {  @channel.unsubscribe(sid) }
      }
    end
  }

  def self.update_clients(object)
    @channel.push(WebSocket.view_hash(object).to_json) if @channel
  end
  
  def self.view_hash(object)
    begin
     puts "I be working hard"
     v = WebSocket.view_for(object)
     puts v.inspect
    
    rescue Exception => e
      puts "in failzord " + v.inspect
      puts object.inspect
      puts e.message
      raise e 
    end
    puts "i made it here"
    {:class =>object.class.to_s.underscore.pluralize, :html => v}
  end
  
  def self.view_for(object)
    @view.render @view.type_partial(object), :post  => object
  end
end
