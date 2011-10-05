class Notifier < ActionMailer::Base
  helper :application
  helper :markdownify
  helper :notifier

  default :from => AppConfig[:smtp_sender_address]

  include NotifierHelper

  def self.admin(string, recipients, opts = {})
    mails = []
    recipients.each do |rec|
      mail = single_admin(string, rec)
      mails << mail
    end
    mails
  end

  def single_admin(string, recipient)
    @receiver = recipient
    @string = string.html_safe
    mail(:to => @receiver.email,
         :subject => I18n.t('notifier.single_admin.subject'), :host => AppConfig[:pod_uri].host)
  end

  def started_sharing(recipient_id, sender_id)
    @notification = NotificationMailers::StartedSharing.new(recipient_id, sender_id)

    with_recipient_locale do
      mail(@notification.headers)
    end
  end

  def liked(recipient_id, sender_id, like_id)
    @notification = NotificationMailers::Liked.new(recipient_id, sender_id, like_id)

    with_recipient_locale do
      mail(@notification.headers)
    end
  end

  def reshared(recipient_id, sender_id, reshare_id)
    @notification = NotificationMailers::Reshared.new(recipient_id, sender_id, reshare_id)

    with_recipient_locale do
      mail(@notification.headers)
    end
  end

  def mentioned(recipient_id, sender_id, target_id)
    @notification = NotificationMailers::Mentioned.new(recipient_id, sender_id, target_id)

    with_recipient_locale do
      mail(@notification.headers)
    end
  end

  def comment_on_post(recipient_id, sender_id, comment_id)
    @notification = NotificationMailers::CommentOnPost.new(recipient_id, sender_id, comment_id)

    with_recipient_locale do
      mail(@notification.headers)
    end
  end

  def also_commented(recipient_id, sender_id, comment_id)
    @notification = NotificationMailers::AlsoCommented.new(recipient_id, sender_id, comment_id)

    with_recipient_locale do
      mail(@notification.headers) if @notification.mail?
    end
  end

  def private_message(recipient_id, sender_id, message_id)
    @notification = NotificationMailers::PrivateMessage.new(recipient_id, sender_id, message_id)

    with_recipient_locale do
      mail(@notification.headers)
    end
  end

  def confirm_email(recipient_id)
    @notification = NotificationMailers::ConfirmEmail.new(recipient_id)

    with_recipient_locale do
      mail(@notification.headers)
    end
  end

  private
  def with_recipient_locale(&block)
    I18n.with_locale(@notification.recipient.language, &block)
  end
end
