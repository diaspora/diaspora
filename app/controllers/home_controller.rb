#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class HomeController < ApplicationController
  def show
    if current_user
      flag = FeatureFlagger.new(current_user, current_user.person)

      if flag.new_profile? && flag.following_enabled?
        redirect_to person_path(current_user.person.guid)
      else
        redirect_to stream_path
      end
    elsif is_mobile_device?
      redirect_to user_session_path
    else
      @landing_page = true
      render :show
    end
  end

  def toggle_mobile
   session[:mobile_view] = !session[:mobile_view]
    redirect_to :back
  end
end
