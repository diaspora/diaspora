class Notifier < ActionMailer::Base
  default :from => "no-reply@joindiaspora.com"
  ATTACHMENT =  File.read("#{Rails.root}/public/images/diaspora_caps.png")  

  def new_request(recipient, sender)
    @receiver = recipient
    @sender = sender
    attachments["diaspora_white.png"] = ATTACHMENT 

    mail(:to => "#{recipient.real_name} <#{recipient.email}>",
    :subject => "new Diaspora* friend request from #{@sender.real_name}", :host => APP_CONFIG[:terse_pod_url])
  end

  def request_accepted(recipient, sender, aspect)
    @receiver = recipient
    @sender = sender
    @aspect = aspect
    attachments["diaspora_white.png"] = ATTACHMENT 
    mail(:to => "#{recipient.real_name} <#{recipient.email}>",
    :subject => "#{@sender.real_name} has accepted your friend request on Diaspora*", :host => APP_CONFIG[:terse_pod_url])
  end
end
