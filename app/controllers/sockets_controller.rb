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

  def outgoing(user, object, opts={})
    @_request = ActionDispatch::Request.new({})
    Diaspora::WebSocket.queue_to_user(user.id, action_hash(user, object, opts))
  end
end
