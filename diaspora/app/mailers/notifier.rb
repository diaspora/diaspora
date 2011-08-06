class Notifier < ActionMailer::Base
  helper :application
  helper :markdownify

  default :from => AppConfig[:smtp_sender_address]

  include ActionView::Helpers::TextHelper

  TRUNCATION_LEN = 70

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
    @receiver = User.find_by_id(recipient_id)
    @sender = Person.find_by_id(sender_id)

    log_mail(recipient_id, sender_id, 'started_sharing')

    I18n.with_locale(@receiver.language) do
      mail(:to => "\"#{@receiver.name}\" <#{@receiver.email}>",
           :subject => I18n.t('notifier.started_sharing.subject', :name => @sender.name), :host => AppConfig[:pod_uri].host)
    end
  end

  def liked(recipient_id, sender_id, like_id)
    @receiver = User.find_by_id(recipient_id)
    @sender = Person.find_by_id(sender_id)
    @like = Like.find(like_id)

    log_mail(recipient_id, sender_id, 'liked')

    I18n.with_locale(@receiver.language) do
      mail(:to => "\"#{@receiver.name}\" <#{@receiver.email}>",
           :subject => I18n.t('notifier.liked.liked', :name => @sender.name), :host => AppConfig[:pod_uri].host)
    end
  end

  def mentioned(recipient_id, sender_id, target_id)
    @receiver = User.find_by_id(recipient_id)
    @sender = Person.find_by_id(sender_id)
    @post = Mention.find_by_id(target_id).post

    log_mail(recipient_id, sender_id, 'mentioned')

    I18n.with_locale(@receiver.language) do
      mail(:to => "\"#{@receiver.name}\" <#{@receiver.email}>",
           :subject => I18n.t('notifier.mentioned.subject', :name => @sender.name), :host => AppConfig[:pod_uri].host)
    end
  end

  def comment_on_post(recipient_id, sender_id, comment_id)
    @receiver = User.find_by_id(recipient_id)
    @sender   = Person.find_by_id(sender_id)
    @comment  = Comment.find_by_id(comment_id)

    log_mail(recipient_id, sender_id, 'comment_on_post')

    I18n.with_locale(@receiver.language) do
      mail(:from => "\"#{@sender.name} (Diaspora)\" <#{AppConfig[:smtp_sender_address]}>",
           :to => "\"#{@receiver.name}\" <#{@receiver.email}>",
           :subject => "Re: #{truncate(@comment.parent.formatted_message(:plain_text => true).strip, :length => TRUNCATION_LEN)}")
    end
  end

  def also_commented(recipient_id, sender_id, comment_id)
    @receiver = User.find_by_id(recipient_id)
    @sender   = Person.find_by_id(sender_id)
    @comment  = Comment.find_by_id(comment_id)
    @post_author_name = @comment.post.author.name


    log_mail(recipient_id, sender_id, 'comment_on_post')

    I18n.with_locale(@receiver.language) do
      mail(:from => "\"#{@sender.name} (Diaspora)\" <#{AppConfig[:smtp_sender_address]}>",
           :to => "\"#{@receiver.name}\" <#{@receiver.email}>",
           :subject => "Re: #{truncate(@comment.parent.formatted_message(:plain_text => true).strip, :length => TRUNCATION_LEN)}")
    end
  end

  def private_message(recipient_id, sender_id, message_id)
    @receiver = User.find_by_id(recipient_id)
    @sender   = Person.find_by_id(sender_id)
    @message  = Message.find_by_id(message_id)
    @conversation = @message.conversation
    @participants = @conversation.participants


    log_mail(recipient_id, sender_id, 'private_message')

    subject = @conversation.subject.strip
    subject = "Re: #{subject}" if @conversation.messages.size > 1


    I18n.with_locale(@receiver.language) do
      mail(:from => "\"#{@sender.name} (Diaspora)\" <#{AppConfig[:smtp_sender_address]}>",
           :to => "\"#{@receiver.name}\" <#{@receiver.email}>",
           :subject => subject)
    end
  end

  def confirm_email(receiver_id)
    @receiver = User.find_by_id(receiver_id)

    I18n.with_locale(@receiver.language) do
      mail(:to => "\"#{@receiver.name}\" <#{@receiver.unconfirmed_email}>",
           :subject => I18n.t('notifier.confirm_email.subject', :unconfirmed_email => @receiver.unconfirmed_email),
           :host => AppConfig[:pod_uri].host)
    end
  end

  private
  def log_mail recipient_id, sender_id, type
    log_string = "event=mail mail_type=#{type} recipient_id=#{recipient_id} sender_id=#{sender_id}"
    if @receiver && @sender
      log_string << "models_found=true sender_handle=#{@sender.diaspora_handle} recipient_handle=#{@receiver.diaspora_handle}"
    else
      log_string << "models_found=false"
    end
    Rails.logger.info log_string
  end
end
