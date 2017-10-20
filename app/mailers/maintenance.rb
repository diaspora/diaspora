# frozen_string_literal: true

class Maintenance < ApplicationMailer
  def account_removal_warning(user)
    @user = user
    @login_url  = new_user_session_url
    @pod_url = AppConfig.environment.url
    @after_days = AppConfig.settings.maintenance.remove_old_users.after_days.to_s
    @remove_after = @user.remove_after

    I18n.with_locale(@user.language) do
      mail(to: @user.email, subject: I18n.t("notifier.remove_old_user.subject")) do |format|
        format.text
        format.html
      end
    end
  end
end
