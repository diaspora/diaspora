# frozen_string_literal: true

class Notifier < ApplicationMailer
  helper :application
  helper :notifier
  helper :people

  def self.admin(string, recipients, opts = {}, subject=nil)
    mails = []
    recipients.each do |rec|
      mail = single_admin(string, rec, opts.dup, subject)
      mails << mail
    end
    mails
  end

  def single_admin(string, recipient, opts={}, subject=nil)
    @receiver = recipient
    @string = string.html_safe

    if attach = opts.delete(:attachments)
      attach.each{ |f|
        attachments[f[:name]] = f[:file]
      }
    end

    unless subject
      subject = I18n.t('notifier.single_admin.subject')
    end

    default_opts = {:to => @receiver.email,
         :from => AppConfig.mail.sender_address,
         :subject => subject, :host => AppConfig.pod_uri.host}
    default_opts.merge!(opts)

    mail(default_opts) do |format|
      format.text
      format.html
    end
  end

  def invite(email, inviter, invitation_code, locale)
    @inviter = inviter
    @invitation_code = invitation_code

    I18n.with_locale(locale) do
      mail_opts = {to: email, from: "\"#{AppConfig.settings.pod_name}\" <#{AppConfig.mail.sender_address}>",
                 subject: I18n.t("notifier.invited_you", name: @inviter.name),
                 host: AppConfig.pod_uri.host}

      mail(mail_opts) do |format|
        format.text { render :layout => nil }
        format.html { render :layout => nil }
      end
    end
  end

  def send_notification(type, *args)
    @notification = NotificationMailers.const_get(type.to_s.camelize).new(*args)

    with_recipient_locale do
      mail(@notification.headers) do |format|
        self.action_name = type
        format.text
        format.html
      end
    end
  end

  private

  def with_recipient_locale(&block)
    I18n.with_locale(@notification.recipient.language, &block)
  end
end
