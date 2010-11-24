class Notifier < ActionMailer::Base
  
  default :from => "no-reply@joindiaspora.com"
  
  ATTACHMENT = File.read("#{Rails.root}/public/images/diaspora_white_on_grey.png")  

  def new_request(recipient_id, sender_id)
    @receiver = User.find_by_id(recipient_id)
    @sender = Person.find_by_id(sender_id)

    log_mail(recipient_id, sender_id, 'new_request')

    attachments.inline['diaspora_white_on_grey.png'] = ATTACHMENT 

    mail(:to => "#{@receiver.real_name} <#{@receiver.email}>",
         :subject => I18n.t('notifier.new_request.subject', :from => @sender.real_name), :host => APP_CONFIG[:terse_pod_url])
  end

  def request_accepted(recipient_id, sender_id, aspect_id)
    @receiver = User.find_by_id(recipient_id)
    @sender = Person.find_by_id(sender_id)
    @aspect = Aspect.find_by_id(aspect_id)

    log_mail(recipient_id, sender_id, 'request_accepted')

    attachments.inline['diaspora_white_on_grey.png'] = ATTACHMENT 

    mail(:to => "#{@receiver.real_name} <#{@receiver.email}>",
          :subject => I18n.t('notifier.request_accepted.subject', :name => @sender.real_name), :host => APP_CONFIG[:terse_pod_url])
  end

  private
  def log_mail recipient_id, sender_id, type
    log_string = "event=mail mail_type=#{type} db_name=#{MongoMapper.database.name} recipient_id=#{recipient_id} sender_id=#{sender_id}"
    if @receiver && @sender
      log_string << "models_found=true sender_handle=#{@sender.diaspora_handle} recipient_handle=#{@receiver.diaspora_handle}"
    else
      log_string << "models_found=false"
    end
    Rails.logger.info log_string
  end
end
