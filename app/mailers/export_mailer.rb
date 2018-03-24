# frozen_string_literal: true

class ExportMailer < ApplicationMailer
  def export_complete_for(user)
    @user = user

    mail(to: @user.email, subject: I18n.t('notifier.export_email.subject', name: @user.name)) do |format|
      format.html { render 'users/export_email' }
      format.text { render 'users/export_email' }
    end
  end

  def export_failure_for(user)
    @user = user

    mail(to: @user.email, subject: I18n.t('notifier.export_failure_email.subject', name: @user.name)) do |format|
      format.html { render 'users/export_failure_email' }
      format.text { render 'users/export_failure_email' }
    end
  end

  def export_photos_complete_for(user)
    @user = user

    mail(to: @user.email, subject: I18n.t('notifier.export_photos_email.subject', name: @user.name)) do |format|
      format.html { render 'users/export_photos_email' }
      format.text { render 'users/export_photos_email' }
    end
  end

  def export_photos_failure_for(user)
    @user = user

    mail(to: @user.email, subject: I18n.t('notifier.export_photos_failure_email.subject', name: @user.name)) do |format|
      format.html { render 'users/export_photos_failure_email' }
      format.text { render 'users/export_photos_failure_email' }
    end
  end
end
