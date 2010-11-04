class Notifier < ActionMailer::Base
  include Magent::Async
  
  default :from => "no-reply@joindiaspora.com"
  ATTACHMENT =  File.read("#{Rails.root}/public/images/diaspora_white_on_grey.png")  

  def new_request(recipient, sender)
    puts "I'm in new request"
    @receiver = recipient
    @sender = sender
    attachments.inline['diaspora_white_on_grey.png'] = ATTACHMENT 

    mail(:to => "#{recipient.real_name} <#{recipient.email}>",
    :subject => "new Diaspora* friend request from #{@sender.real_name}", :host => APP_CONFIG[:terse_pod_url])
  end

  def request_accepted(recipient, sender, aspect)
    @receiver = recipient
    @sender = sender
    @aspect = aspect
    attachments.inline['diaspora_white_on_grey.png'] = ATTACHMENT 

    mail(:to => "#{recipient.real_name} <#{recipient.email}>",
    :subject => "#{@sender.real_name} has accepted your friend request on Diaspora*", :host => APP_CONFIG[:terse_pod_url])
  end


  def self.send_request_accepted!(user, person, aspect)
    Notifier.async.request_accepted(user, person, aspect ).deliver.commit!
  end

  def self.send_new_request!(user, person)
    Notifier.async.new_request(user, person).deliver.commit!
  end
end
