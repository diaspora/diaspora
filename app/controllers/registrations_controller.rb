#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class RegistrationsController < Devise::RegistrationsController
  before_filter :check_registrations_open_or_vaild_invite!, :check_valid_invite!

  layout "with_header", :only => [:new]
  before_filter -> { @css_framework = :bootstrap }, only: [:new]

  def create
    @user = User.build(params[:user])
    @user.process_invite_acceptence(invite) if invite.present?

    if @user.save
      flash[:notice] = I18n.t 'registrations.create.success'
      @user.seed_aspects
      sign_in_and_redirect(:user, @user)
      Rails.logger.info("event=registration status=successful user=#{@user.diaspora_handle}")
    else
      @user.errors.delete(:person)

      flash[:error] = @user.errors.full_messages.join(" - ")
      Rails.logger.info("event=registration status=failure errors='#{@user.errors.full_messages.join(', ')}'")
      redirect_to :back
    end
  end

  def new
    super
  end

  private

  def check_valid_invite!
    return true if AppConfig.settings.enable_registrations? #this sucks
    return true if invite && invite.can_be_used?
    flash[:error] = t('registrations.invalid_invite')
    redirect_to new_user_session_path
  end

  def check_registrations_open_or_vaild_invite!
    return true if invite.present?
    unless AppConfig.settings.enable_registrations?
      flash[:error] = t('registrations.closed')
      redirect_to new_user_session_path
    end
  end

  def invite
    if params[:invite].present?
      @invite ||= InvitationCode.find_by_token(params[:invite][:token])
    end
  end

  helper_method :invite
end
