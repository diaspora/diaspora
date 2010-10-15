#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class InvitationsController < Devise::InvitationsController
  def create
    begin
      self.resource = current_user.invite_user(params[resource_name])
      flash[:notice] = I18n.t 'invitations.create.sent'
    rescue RuntimeError => e
      if  e.message == "You have no invites"
        flash[:error] = I18n.t 'invitations.create.no_more'
      elsif e.message == "You already invited this person"
        flash[:error] = I18n.t 'invitations.create.already_sent'
      
      else
        raise e
      end
    end
    redirect_to after_sign_in_path_for(resource_name)
  end

  def update
    begin
      user = User.find_by_invitation_token(params["user"]["invitation_token"])
      user.accept_invitation!(params["user"])
    rescue MongoMapper::DocumentNotValid => e
      user = nil
      flash[:error] = e.message
    end
    if user
      flash[:notice] = I18n.t 'registrations.create.success'
      sign_in_and_redirect(:user, user)
    else
      redirect_to new_user_registration_path
    end
  end
end
