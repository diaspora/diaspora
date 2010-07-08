class SocketController < ApplicationController 
  include ApplicationHelper
  include SocketHelper
  include Rails.application.routes.url_helpers
  before_filter :authenticate_user! 
  
  
  
 # def default_url_options()
 #   {:host=> 'example.com'}
 # end

  def incoming(msg)
    puts "#{msg} connected!"
  end
  
  def new_subscriber
    WebSocket.subscribe
  end
  
  def outgoing(object)
    begin 
    @_request = ActionDispatch::Request.new(:socket => true)
    WebSocket.push_to_clients(action_hash(object))
    rescue Exception => e
      puts e.inspect
      raise e
    end
  end
  
  def delete_subscriber(sid)
    WebSocket.unsubscribe(sid)
  end


end
