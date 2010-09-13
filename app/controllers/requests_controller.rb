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


class RequestsController < ApplicationController
  before_filter :authenticate_user!
  include RequestsHelper 

  respond_to :html
  respond_to :json, :only => :index

  def index
    @remote_requests = Request.for_user current_user
    @request         = Request.new

    respond_with @remote_requests
  end
  
  def destroy
    if params[:accept]
      if params[:aspect_id]
        @friend = current_user.accept_and_respond( params[:id], params[:aspect_id])
        flash[:notice] = "you are now friends"
        respond_with :location => current_user.aspect_by_id(params[:aspect_id])
      else
        flash[:error] = "please select a aspect!"
        respond_with :location => requests_url
      end
    else
      current_user.ignore_friend_request params[:id]
      respond_with :location => requests_url, :notice => "Ignored friend request."
    end
  end
  
  def new
    @request = Request.new
  end
  
  def create
    aspect = current_user.aspect_by_id(params[:request][:aspect_id])

    begin 
      rel_hash = relationship_flow(params[:request][:destination_url])
    rescue Exception => e
      respond_with :location => aspect, :error => "No diaspora seed found with this email!" 
      return
    end
    
    Rails.logger.debug("Sending request: #{rel_hash}")
    
    begin
      @request = current_user.send_friend_request_to(rel_hash[:friend], aspect)
    rescue Exception => e
      raise e unless e.message.include? "already friends"
      message = "You are already friends with #{params[:request][:destination_url]}!"
      respond_with :location => aspect, :notice => message
      return
    end

    if @request
      message = "A friend request was sent to #{@request.destination_url}."
      respond_with :location => aspect, :notice => message
    else
      message = "Something went horribly wrong."
      respond_with :location => aspect, :error => message
    end
  end

end
