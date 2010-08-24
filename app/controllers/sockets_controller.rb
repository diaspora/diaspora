class SocketsController < ApplicationController 
  include ApplicationHelper
  include SocketsHelper
  include Rails.application.routes.url_helpers

  def incoming(msg)
    Rails.logger.info("Socket received connection to: #{msg}")
  end
  
  def outgoing(uid,object,opts={})
    @_request = ActionDispatch::Request.new({})
    Diaspora::WebSocket.push_to_user(uid, action_hash(uid, object, opts))
  end
  
end
