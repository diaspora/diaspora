class SocketsController < ApplicationController 
  include ApplicationHelper
  include SocketsHelper
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
    @_request = ActionDispatch::Request.new({})
    
    puts action_hash(object)
    
    
    
    WebSocket.push_to_clients(action_hash(object))
  end
  
  def delete_subscriber(sid)
    WebSocket.unsubscribe(sid)
  end


end
