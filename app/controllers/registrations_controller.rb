#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3.  See
#   the COPYRIGHT file.

class RegistrationsController < Devise::RegistrationsController
  def new
    super
  end

  def create
    begin 
      user = User.instantiate!(params[:user])
    rescue MongoMapper::DocumentNotValid => e
      user = nil
      flash[:error] = e.message
    end
    if user
      #set_flash_message :notice, :signed_up
      flash[:notice] = "You've joined Diaspora!"
      #redirect_to root_url
      sign_in_and_redirect(:user, user)
    else
      redirect_to "/get_to_the_choppa"
    end
  end

  def update
    super
  end
end
