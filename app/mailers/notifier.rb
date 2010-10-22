class Notifier < ActionMailer::Base
  default :from => "no-reply@joindiaspora.com"
  
  def new_request(recipient, sender)
    @receiver = recipient
    @sender = sender
    attachments["diaspora_white.png"] = File.read("#{Rails.root}/public/images/diaspora_white.png")  

    mail(:to => "#{recipient.real_name} <#{recipient.email}>",
    :subject => "new Diaspora* friend request from #{@sender.real_name}", :host => APP_CONFIG[:terse_pod_url])
  end

  def request_accepted(recipient, sender, aspect)
    @receiver = recipient
    @sender = sender
    @aspect = aspect
    attachments["diaspora_white.png"] = File.read("#{Rails.root}/public/images/diaspora_white.png")  
    mail(:to => "#{recipient.real_name} <#{recipient.email}>",
    :subject => "#{@sender.real_name} has accepted your friend request on Diaspora*", :host => APP_CONFIG[:terse_pod_url])
  end
end
