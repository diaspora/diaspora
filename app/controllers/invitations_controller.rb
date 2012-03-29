#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require Rails.root.join('lib', 'email_inviter')

class InvitationsController < ApplicationController

  def new
    @invite_code = current_user.invitation_code
    respond_to do |format|
      format.html do
        render :layout => false
      end
    end
  end

  # this is  for legacy invites.  We try to look the person who sent them the 
  # invite, and use their new invite code
  # owe will be removing this eventually
  # @depreciated
  def edit
    user = User.find_by_invitation_token(params[:invitation_token])
    invitation_code = user.ugly_accept_invitation_code
    redirect_to invite_code_path(invitation_code)
  end

  def email
    if params[:invitation_token]
      # this is  for legacy invites.
      user = User.find_by_invitation_token(params[:invitation_token])
      @invitation_code = user.ugly_accept_invitation_code
    else
      @invitation_code = params[:invitation_code]
    end
    render 'notifier/invite', :layout => false
  end

  def create
    inviter = EmailInviter.new(params[:email_inviter][:emails], current_user, params[:email_inviter])
    inviter.send!
    redirect_to :back, :notice => "Great! Invites were sent off to #{inviter.emails.join(', ')}" 
  end

  def check_if_invites_open
    unless AppConfig[:open_invitations]
      flash[:error] = I18n.t 'invitations.create.no_more'
      redirect_to :back
      return
    end
  end
end