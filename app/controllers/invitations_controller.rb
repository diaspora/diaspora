#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class InvitationsController < Devise::InvitationsController

  before_filter :check_token, :only => [:edit] 


  def create
    begin
      params[:user][:aspect_id] = params[:user].delete(:aspects)
      message = params[:user].delete(:invite_messages)
      params[:user][:invite_message] = message unless message == ""
      self.resource = current_user.invite_user(params[resource_name])
      flash[:notice] = I18n.t 'invitations.create.sent'
    rescue RuntimeError => e
      if  e.message == "You have no invites"
        flash[:error] = I18n.t 'invitations.create.no_more'
      elsif e.message == "You already invited this person"
        flash[:error] = I18n.t 'invitations.create.already_sent'
      elsif e.message == "You are already connected to this person"
        flash[:error] = I18n.t 'invitations.create.already_contacts'
      else
        raise e
      end
    end
    redirect_to after_sign_in_path_for(resource_name)
  end

  def update
    begin
      user = User.find_by_invitation_token(params[:user][:invitation_token])
      user.accept_invitation!(params[:user])
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

  protected

  def check_token
    if User.find_by_invitation_token(params[:invitation_token]).nil?
      flash[:error] = I18n.t 'invitations.check_token.not_found'
      redirect_to root_url
    end
  end
end
