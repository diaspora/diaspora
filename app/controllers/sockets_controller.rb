#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class SocketsController < ApplicationController
  include ApplicationHelper
  include SocketsHelper
  include Rails.application.routes.url_helpers

  def incoming(msg)
    Rails.logger.info("Socket received connection to: #{msg}")
  end

  def outgoing(user_or_id, object, opts={})
    if user_or_id.instance_of?(Fixnum)
      user_id = user_or_id
    else
      user_id = user_or_id.id
      @user = user_or_id
    end
    return unless Diaspora::WebSocket.is_connected?(user_id)
    @_request = ActionDispatch::Request.new({})
    Diaspora::WebSocket.queue_to_user(user_id, action_hash(@user || User.find(user_id), object, opts))
  end
end
