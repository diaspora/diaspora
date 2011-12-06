#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class InvitationsController < Devise::InvitationsController

  before_filter :check_token, :only => [:edit, :email]
  before_filter :check_if_invites_open, :only =>[:create]

  def new
    @sent_invitations = current_user.invitations_from_me.includes(:recipient)
    respond_to do |format|
      format.html do
        render :layout => false
      end
    end
  end

  def create
    aspect_id = params[:user].delete(:aspects)
    message = params[:user].delete(:invite_messages)
    emails = params[:user][:email].to_s.gsub(/\s/, '').split(/, */)
    #NOTE should we try and find users by email here? probs
    aspect = current_user.aspects.find(aspect_id)
    
    language = params[:user][:language]

    invites = Invitation.batch_invite(emails, :message => message, :sender => current_user, :aspect => aspect, :service => 'email', :language => language)

    flash[:notice] = extract_messages(invites)

    redirect_to :back
  end

  def update
    invitation_token = params[:user][:invitation_token]

    if invitation_token.nil? || invitation_token.blank?
      redirect_to :back, :error => I18n.t('invitations.check_token.not_found')
      return
    end

    user = User.find_by_invitation_token!(invitation_token)

    user.accept_invitation!(params[:user])

    if user.persisted? && user.person && user.person.persisted?
      user.seed_aspects
      flash[:notice] = I18n.t 'registrations.create.success'
      sign_in_and_redirect(:user, user)
    else
      user.errors.delete(:person)
      flash[:error] = user.errors.full_messages.join(", ")
      redirect_to accept_user_invitation_path(:invitation_token => params[:user][:invitation_token])
    end
  end

  def resend
    invitation = current_user.invitations_from_me.where(:id => params[:id]).first
    if invitation
      Resque.enqueue(Jobs::ResendInvitation, invitation.id)
      flash[:notice] = I18n.t('invitations.create.sent') + invitation.recipient.email
    end
    redirect_to :back
  end

  def email
    @invs = []
    @resource = User.find_by_invitation_token(params[:invitation_token])
    render 'devise/mailer/invitation_instructions', :layout => false
  end

  protected
  def check_token
    if User.find_by_invitation_token(params[:invitation_token]).nil?
      render 'invitations/token_not_found'
    end
  end

  def check_if_invites_open
    unless AppConfig[:open_invitations]
      flash[:error] = I18n.t 'invitations.create.no_more'
      redirect_to :back
      return
    end
  end

  # @param invites [Array<Invitation>] Invitations to be sent.
  # @return [String] A full list of success and error messages.
  def extract_messages(invites)
    success_message = "Invites Successfully Sent to: "
    failure_message = "There was a problem with: "
    following_message = " already are on Diaspora, so you are now sharing with them."
    successes, failures = invites.partition{|x| x.persisted? }

    followings, real_failures = failures.partition{|x| x.errors[:recipient].present? }

    success_message += successes.map{|k| k.identifier }.to_sentence
    failure_message += real_failures.map{|k| k.identifier }.to_sentence
    following_message += followings.map{|k| k.identifier}.to_sentence

    messages = []
    messages << success_message if successes.present?
    messages << failure_message if failures.present?
    messages << following_message if followings.present?

    messages.join('\n')
  end
end
