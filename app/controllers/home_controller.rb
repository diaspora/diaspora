#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class HomeController < ApplicationController

  def show
    if current_user
      redirect_to aspects_path
    elsif is_mobile_device?
      redirect_to user_session_path
    else
      @landing_page = true
      render :show
    end
  end
end
