#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class HomeController < ApplicationController

  def show
    if current_user
      if params[:home]
        redirect_to :controller => 'aspects', :action => 'index'
      else
        redirect_to :controller => 'aspects', :action => 'index', :a_ids => current_user.aspects.where(:open => true).select(:id).all
      end
    elsif is_mobile_device?
      redirect_to user_session_path
    else
      @landing_page = true
      render :show
    end
  end

  def toggle_mobile
   if session[:mobile_view]
     session[:mobile_view] = false
   else
     session[:mobile_view] = true
   end
    redirect_to :back
  end
end
