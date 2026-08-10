# frozen_string_literal: true

class WelcomeMailer < ApplicationMailer
  def send_welcome_email(user)
    @user = user
    @podmin_message = podmin_message
    mail(to: @user.email, reply_to: AppConfig.admins.podmin_email.presence,
         subject: I18n.t("registrations.welcome_email.subject")) do |format|
      format.text { render "registrations/welcome_email" }
      format.html { render "registrations/welcome_email" }
    end
  end

  private

  def podmin_message
    return unless AppConfig.settings.welcome_message.enabled?
    AppConfig.settings.welcome_message.text.get
  end
end
