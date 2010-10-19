#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class RegistrationsController < Devise::RegistrationsController
  def create
    begin
      user = User.instantiate!(params[:user])
    rescue MongoMapper::DocumentNotValid => e
      flash[:error] = e.message
      redirect_to new_user_registration_path
    end
    if user.save
      flash[:notice] = I18n.t 'registrations.create.success'
      sign_in_and_redirect(:user, user)
    else
      flash[:error] = user.errors.full_messages.join(', ')
      redirect_to new_user_registration_path
    end
  end

    def update
    super
  end
end
