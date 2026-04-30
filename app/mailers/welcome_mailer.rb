# frozen_string_literal: true

class WelcomeMailer < ApplicationMailer
  def send_welcome_email(user)
    @user = user
    mail(to: @user.email, subject: I18n.t("registrations.welcome_email.subject")) do |format|
      format.html { render "registrations/welcome_email" }
    end
  end
end
