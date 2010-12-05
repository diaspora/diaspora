#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class InvitationsController < Devise::InvitationsController

  before_filter :check_token, :only => [:edit] 


  def create
      if current_user.invites == 0
        flash[:error] = I18n.t 'invitations.create.no_more'
        redirect_to :back
        return
      end
      aspect = params[:user].delete(:aspects)
      message = params[:user].delete(:invite_messages)
      emails = params[:user][:email].split(/, */)

      good_emails, bad_emails = emails.partition{|e| e.try(:match, Devise.email_regexp)}

      good_emails.each{|e| Resque.enqueue(Jobs::InviteUser, current_user.id, e, aspect, message)}

      if bad_emails.any?
        flash[:error] = I18n.t('invitations.create.sent') + good_emails.join(', ') + " "+ I18n.t('invitations.create.rejected') + bad_emails.join(', ')
      else
        flash[:notice] = I18n.t('invitations.create.sent') + good_emails.join(', ')
      end

    redirect_to :back 
  end

  def update
    begin
      puts "foobar"
      puts params.inspect
      user = User.find_by_invitation_token(params[:user][:invitation_token])
      puts user.inspect
      user.seed_aspects
      user.accept_invitation!(params[:user])
    rescue MongoMapper::DocumentNotValid => e
      user = nil
      flash[:error] = e.message
    end

    if user
      flash[:notice] = I18n.t 'registrations.create.success'
      sign_in_and_redirect(:user, user)
    else
      redirect_to accept_user_invitation_path(
        :invitation_token => params[:user][:invitation_token])
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
