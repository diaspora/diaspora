# frozen_string_literal: true

class ExportMailer < ApplicationMailer
  def export_complete_for(user)
    send_mail(user, I18n.t("notifier.export_email.subject", name: user.name),
              I18n.t("notifier.export_email.body", url: download_profile_user_url, name: user.first_name))
  end

  def export_failure_for(user)
    send_mail(user, I18n.t("notifier.export_failure_email.subject", name: user.name),
              I18n.t("notifier.export_failure_email.body", name: user.first_name))
  end

  def export_photos_complete_for(user)
    send_mail(user, I18n.t("notifier.export_photos_email.subject", name: user.name),
              I18n.t("notifier.export_photos_email.body", url: download_photos_user_url, name: user.first_name))
  end

  def export_photos_failure_for(user)
    send_mail(user, I18n.t("notifier.export_photos_failure_email.subject", name: user.name),
              I18n.t("notifier.export_photos_failure_email.body", name: user.first_name))
  end

  private

  def send_mail(user, subject, body)
    mail(to: user.email, subject: subject) do |format|
      format.html { render "notifier/plain_markdown_email", locals: {body: body} }
      format.text { render "notifier/plain_markdown_email", locals: {body: body} }
    end
  end
end
