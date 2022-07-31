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

    subject ||= I18n.t("notifier.single_admin.subject")

    default_opts = {to: @receiver.email, from: AppConfig.mail.sender_address, subject: subject}
    default_opts.merge!(opts)

    mail(default_opts)
  end

  def invite(email, inviter, invitation_code, locale)
    I18n.with_locale(locale) do
      mail_opts = {to: email, from: "\"#{AppConfig.settings.pod_name}\" <#{AppConfig.mail.sender_address}>",
                 subject: I18n.t("notifier.invited_you", name: inviter.name)}
      name = inviter.full_name.empty? ? inviter.diaspora_handle : "#{inviter.name} (#{inviter.diaspora_handle})"
      body = I18n.t("notifier.invite.message",
                    invite_url:             invite_code_url(invitation_code),
                    diasporafoundation_url: "https://diasporafoundation.org/",
                    user:                   name,
                    diaspora_id:            inviter.diaspora_handle)

      mail(mail_opts) do |format|
        format.text { render "notifier/plain_markdown_email", layout: nil, locals: {body: body} }
        format.html { render "notifier/plain_markdown_email", layout: nil, locals: {body: body} }
      end
    end
  end

  def send_notification(type, *args)
    @notification = NotificationMailers.const_get(type.camelize).new(*args)

    with_recipient_locale do
      mail(@notification.headers)
    end
  end

  private

  def with_recipient_locale(&block)
    I18n.with_locale(@notification.recipient.language, &block)
  end
end
