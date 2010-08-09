class SocketsController < ApplicationController 
  include ApplicationHelper
  include SocketsHelper
  include Rails.application.routes.url_helpers

  def incoming(msg)
    puts "Got a connection to: #{msg}"
  end
  
  def outgoing(uid,object)
    @_request = ActionDispatch::Request.new({})
    WebSocket.push_to_user(uid, action_hash(uid, object))
  end
  
end
