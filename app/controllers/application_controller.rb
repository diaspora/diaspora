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


class ApplicationController < ActionController::Base
  
  protect_from_forgery :except => :receive
  
  before_filter :set_friends_and_status
  before_filter :count_requests

  layout :layout_by_resource

  def layout_by_resource
    if devise_controller?
      "session_wall"
    else
      "application"
    end
  end
  
  def set_friends_and_status
    if current_user
      if params[:aspect] == 'all' || params[:aspect] == nil
        @aspect = :all
      else
        @aspect = current_user.aspect_by_id( params[:aspect])
      end
      
      @aspects = current_user.aspects
      @friends = current_user.friends
    end
  end

  def count_requests
    @request_count = Request.for_user(current_user).size if current_user
  end
  
end
