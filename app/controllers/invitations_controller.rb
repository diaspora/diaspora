# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class InvitationsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_invitations_available!, only: :create

  def new
    @invite_code = current_user.invitation_code

    @invalid_emails = html_safe_string_from_session_array(:invalid_email_invites)
    @valid_emails   = html_safe_string_from_session_array(:valid_email_invites)

    respond_to do |format|
      format.html do
        render "invitations/new", layout: false
      end
    end
  end

  def create
    emails = inviter_params[:emails].split(",").map(&:strip).uniq

    valid_emails, invalid_emails = emails.partition {|email| valid_email?(email) }

    session[:valid_email_invites] = valid_emails
    session[:invalid_email_invites] = invalid_emails

    unless valid_emails.empty?
      Workers::Mail::InviteEmail.perform_async(valid_emails.join(","), current_user.id, inviter_params)
    end

    if emails.empty?
      flash[:error] = t("invitations.create.empty")
    elsif invalid_emails.empty?
      flash[:notice] = t("invitations.create.sent", emails: valid_emails.join(", "))
    elsif valid_emails.empty?
      flash[:error] = t("invitations.create.rejected", emails: invalid_emails.join(", "))
    else
      flash[:error] = t("invitations.create.sent", emails: valid_emails.join(", ")) + ". " +
        t("invitations.create.rejected", emails: invalid_emails.join(", "))
    end

    redirect_back fallback_location: stream_path
  end

  private

  def check_invitations_available!
    return true if AppConfig.settings.enable_registrations? || current_user.invitation_code.can_be_used?

    flash[:error] = if AppConfig.settings.invitations.open?
                      t("invitations.create.no_more")
                    else
                      t("invitations.create.closed")
                    end
    redirect_back fallback_location: stream_path
  end

  def valid_email?(email)
    User.email_regexp.match(email).present?
  end

  def html_safe_string_from_session_array(key)
    return "" unless session[key].present?
    return "" unless session[key].respond_to?(:join)
    value = session[key].join(", ").html_safe
    session[key] = nil
    value
  end

  def inviter_params
    params.require(:email_inviter).permit(:message, :locale, :emails).to_h
  end
end
