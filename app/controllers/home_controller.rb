# frozen_string_literal: true

#   Copyright (c) 2010-2012, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class HomeController < ApplicationController
  def show
    partial_dir = Rails.root.join("app", "views", "home")
    if user_signed_in?
      redirect_to stream_path
    elsif request.format == :mobile
      if partial_dir.join("_show.mobile.haml").exist? ||
         partial_dir.join("_show.mobile.erb").exist? ||
         partial_dir.join("_show.haml").exist?
        render :show
      else
        redirect_to user_session_path
      end
    elsif partial_dir.join("_show.html.haml").exist? ||
          partial_dir.join("_show.html.erb").exist? ||
          partial_dir.join("_show.haml").exist?
      render :show
    elsif Role.admins.any?
      render :default
    else
      redirect_to podmin_path
    end
  end

  def podmin
    render :podmin
  end

  def toggle_mobile
    session[:mobile_view] = session[:mobile_view].nil? ? true : !session[:mobile_view]

    redirect_back fallback_location: root_path
  end

  def force_mobile
    session[:mobile_view] = true

    redirect_to stream_path
  end
end
