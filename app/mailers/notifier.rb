class Notifier < ActionMailer::Base
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

  def invite(email, message, inviter, invitation_code, locale)
    @inviter = inviter
    @message = message
    @locale = locale
    @invitation_code = invitation_code

    I18n.with_locale(locale) do
      mail_opts = {:to => email, :from => AppConfig.mail.sender_address,
                 :subject => I18n.t('notifier.invited_you', :name => @inviter.name),
                 :host => AppConfig.pod_uri.host}

      mail(mail_opts) do |format|
        format.text { render :layout => nil }
        format.html { render :layout => nil }
      end
    end
  end

  def started_sharing(recipient_id, sender_id)
    send_notification(:started_sharing, recipient_id, sender_id)
  end

  def liked(recipient_id, sender_id, like_id)
    send_notification(:liked, recipient_id, sender_id, like_id)
  end

  def reshared(recipient_id, sender_id, reshare_id)
    send_notification(:reshared, recipient_id, sender_id, reshare_id)
  end

  def mentioned(recipient_id, sender_id, target_id)
    send_notification(:mentioned, recipient_id, sender_id, target_id)
  end

  def comment_on_post(recipient_id, sender_id, comment_id)
    send_notification(:comment_on_post, recipient_id, sender_id, comment_id)
  end

  def also_commented(recipient_id, sender_id, comment_id)
    send_notification(:also_commented, recipient_id, sender_id, comment_id)
  end

  def private_message(recipient_id, sender_id, message_id)
    send_notification(:private_message, recipient_id, sender_id, message_id)
  end

  def confirm_email(recipient_id)
    send_notification(:confirm_email, recipient_id)
  end

  def csrf_token_fail(recipient_id)
    send_notification(:csrf_token_fail, recipient_id)
  end

  private
  def send_notification(type, *args)
    @notification = NotificationMailers.const_get(type.to_s.camelize).new(*args)

    with_recipient_locale do
      mail(@notification.headers) do |format|
        format.text
        format.html
      end
    end
  end

  def with_recipient_locale(&block)
    I18n.with_locale(@notification.recipient.language, &block)
  end
end
