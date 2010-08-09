class SocketsController < ApplicationController 
  include ApplicationHelper
  include SocketsHelper
  include Rails.application.routes.url_helpers
  before_filter :authenticate_user! 

  def incoming(msg)
    puts "#{msg} connected!"
  end
  
  def outgoing(object)
    @_request = ActionDispatch::Request.new({})
    WebSocket.push_to_clients(action_hash(object))
  end
  
  def delete_subscriber(sid)
    WebSocket.unsubscribe(sid)
  end
end
