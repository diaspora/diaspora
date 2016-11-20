#   Copyright (c) 2010-2012, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class HomeController < ApplicationController
  def show
    if user_signed_in?
      redirect_to stream_path
    else
      redirect_to new_user_session_path
    end
  end

  def toggle_mobile
    session[:mobile_view] = session[:mobile_view].nil? ? true : !session[:mobile_view]

    redirect_to :back
  end

  def force_mobile
    session[:mobile_view] = true

    redirect_to stream_path
  end
end
