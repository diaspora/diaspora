class Notifier < ActionMailer::Base
  
  default :from => "no-reply@joindiaspora.com"
  
  ATTACHMENT = File.read("#{Rails.root}/public/images/diaspora_white_on_grey.png")  

  def new_request(recipient_id, sender_id)
    @receiver = User.find_by_id(recipient_id)
    @sender = Person.find_by_id(sender_id)

    attachments.inline['diaspora_white_on_grey.png'] = ATTACHMENT 
  
    mail(:to => "#{@receiver.real_name} <#{@receiver.email}>",
         :subject => I18n.t('notifier.new_request.subject', :from => @sender.real_name), :host => APP_CONFIG[:terse_pod_url])
  end

  def request_accepted(recipient_id, sender_id, aspect_id)
    @receiver = User.find_by_id(recipient_id)
    @sender = Person.find_by_id(sender_id)
    @aspect = Aspect.find_by_id(aspect_id)
    attachments.inline['diaspora_white_on_grey.png'] = ATTACHMENT 

    mail(:to => "#{@receiver.real_name} <#{@receiver.email}>",
          :subject => I18n.t('notifier.request_accepted.subject', :name => @sender.real_name), :host => APP_CONFIG[:terse_pod_url])
  end
end
