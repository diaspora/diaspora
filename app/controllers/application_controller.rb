#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.


class ApplicationController < ActionController::Base

  protect_from_forgery :except => :receive

  before_filter :set_friends_and_status, :except => [:create, :update]
  before_filter :count_requests
  before_filter :fb_user_info

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
      if params[:aspect] == nil || params[:aspect] == 'all'
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

  def fb_user_info
    @access_token = session[:access_token]
    @logged_in = @access_token.present?
  end

end
