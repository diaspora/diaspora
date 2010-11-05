class Notifier < ActionMailer::Base
  include Magent::Async
  
  default :from => "no-reply@joindiaspora.com"
  ATTACHMENT =  File.read("#{Rails.root}/public/images/diaspora_white_on_grey.png")  

  def new_request(recipient_id, sender_id)
    @receiver = User.find_by_id(recipient_id)
    @sender = Person.find_by_id(sender_id)
    puts "#{@receiver}"
    puts "#{@sender}"
    attachments.inline['diaspora_white_on_grey.png'] = ATTACHMENT 
  
    mail(:to => "#{@receiver.real_name} <#{@reciever.email}>",
    :subject => "new Diaspora* friend request from #{@sender.real_name}", :host => APP_CONFIG[:terse_pod_url])
  end

  def request_accepted(recipient_id, sender_id, aspect_id)
    @receiver = User.find_by_id(recipient_id)
    @sender = Person.find_by_id(sender_id)
    @aspect = Aspect.find_by_id(aspect_id)
    puts "fooooo"
    attachments.inline['diaspora_white_on_grey.png'] = ATTACHMENT 

    mail(:to => "#{@receiver.real_name} <#{@receiver.email}>",
    :subject => "#{@sender.real_name} has accepted your friend request on Diaspora*", :host => APP_CONFIG[:terse_pod_url])
  end


  def self.send_request_accepted!(user, person, aspect)
    Notifier.async.request_accepted(user.id, person.id, aspect.id ).deliver.commit!
  end

  def self.send_new_request!(user, person)
    Notifier.async.new_request(user.id, person.id).deliver.commit!
  end
end
