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


class StatusMessagesController < ApplicationController
  before_filter :authenticate_user!

  respond_to :html
  respond_to :json, :only => :show

  def create
    params[:status_message][:to] = params[:aspect_ids]
    @status_message = current_user.post(:status_message, params[:status_message])
    respond_with @status_message
  end
  
  def destroy
    @status_message = StatusMessage.find_by_id params[:id]
    @status_message.destroy
    respond_with :location => root_url
  end
  
  def show
    @status_message = StatusMessage.find_by_id params[:id]
    respond_with @status_message
  end
end
