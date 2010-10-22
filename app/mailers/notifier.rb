class Notifier < ActionMailer::Base
  default :from => "no-reply@joindiaspora.com"
  
  def new_request(recipient, sender)
    @receiver = recipient
    @sender = sender
    mail(:to => "#{recipient.real_name} <#{recipient.email}>",
    :subject => "new friend request from #{@sender.inspect}")
  end
end
