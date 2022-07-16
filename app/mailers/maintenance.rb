# frozen_string_literal: true

class Maintenance < ApplicationMailer
  def account_removal_warning(user)
    I18n.with_locale(user.language) do
      body = I18n.t("notifier.remove_old_user.body",
                    pod_url:      AppConfig.environment.url,
                    login_url:    new_user_session_url,
                    after_days:   AppConfig.settings.maintenance.remove_old_users.after_days.to_s,
                    remove_after: user.remove_after)
      mail(to: user.email, subject: I18n.t("notifier.remove_old_user.subject")) do |format|
        format.text { render "notifier/plain_markdown_email", locals: {body: body} }
        format.html { render "notifier/plain_markdown_email", locals: {body: body} }
      end
    end
  end
end
