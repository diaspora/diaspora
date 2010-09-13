#    Copyright 2010 Diaspora Inc.
#
#    This file is part of Diaspora.
#
#    Diaspora is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    Diaspora is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with Diaspora.  If not, see <http://www.gnu.org/licenses/>.
#


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
