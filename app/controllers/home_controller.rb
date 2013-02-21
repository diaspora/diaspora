#   Copyright (c) 2010-2012, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class HomeController < ApplicationController
  def show
    partial_dir = Rails.root.join('app', 'views', 'home')
    if user_signed_in?
      redirect_to stream_path
    elsif is_mobile_device?
      if partial_dir.join('_show.mobile.haml').exist? ||
         partial_dir.join('_show.mobile.erb').exist?
        render :show, layout: 'post'
      else
        redirect_to user_session_path
      end
    elsif partial_dir.join("_show.html.haml").exist? ||
          partial_dir.join("_show.html.erb").exist?
      render :show, layout: 'post'
    else
        render file: Rails.root.join("public", "default.html"),
               layout: 'post'
    end
  end

  def toggle_mobile
    if session[:mobile_view].nil?
      # we're most probably not on mobile, but user wants it anyway
      session[:mobile_view] = true
    else
      # switch from mobile to normal html
      session[:mobile_view] = !session[:mobile_view]
    end

    redirect_to :back
  end
end
