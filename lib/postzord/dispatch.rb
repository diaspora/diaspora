#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Postzord::Dispatch
  def initialize(user, object)
    unless object.respond_to? :to_diaspora_xml
      raise 'this object does not respond_to? to_diaspora xml.  try including Diaspora::Webhooks into your object'
    end
    @sender = user
    @sender_person = @sender.person
    @object = object
    @xml = @object.to_diaspora_xml
    @subscribers = @object.subscribers(@sender)
  end

  def salmon
    @salmon_factory ||= Salmon::SalmonSlap.create(@sender, @xml)
  end

  def post(opts = {})
    unless @subscribers == nil
      remote_people, local_people = @subscribers.partition{ |person| person.owner_id.nil? }

      if @object.is_a?(Comment) && @sender.owns?(@object.post)
        user_ids = [*local_people].map{|x| x.owner_id }
        local_users = User.where(:id => user_ids)
        self.notify_users(local_users)
        local_users << @sender if @object.person.local?
        self.socket_to_users(local_users)
      else
        self.deliver_to_local(local_people)
      end

      self.deliver_to_remote(remote_people)
    end
    self.deliver_to_services(opts[:url])
  end

  protected

  def deliver_to_remote(people)
    people.each do |person|
      enc_xml = salmon.xml_for(person)
      Rails.logger.info("event=deliver_to_remote route=remote sender=#{@sender.person.diaspora_handle} recipient=#{person.diaspora_handle} payload_type=#{@object.class}")
      Resque.enqueue(Job::HttpPost, person.receive_url, enc_xml)
    end
  end

  def deliver_to_local(people)
    people.each do |person|
      Rails.logger.info("event=push_to_local_person route=local sender=#{@sender_person.diaspora_handle} recipient=#{person.diaspora_handle} payload_type=#{@object.class}")
      Resque.enqueue(Job::Receive, person.owner_id, @xml, @sender_person.id)
    end
  end

  def deliver_to_hub
    Rails.logger.debug("event=post_to_service type=pubsub sender_handle=#{@sender.diaspora_handle}")
    Resque.enqueue(Job::PublishToHub, @sender.public_url)
  end

  def deliver_to_services(url)
    if @object.respond_to?(:public) && @object.public
      deliver_to_hub
      if @object.respond_to?(:message)
        @sender.services.each do |service|
          Resque.enqueue(Job::PostToService, service.id, @object.id, url)
        end
      end
    end
  end

  def socket_and_notify_users(users)
    notify_users(users)
    socket_to_users(users)
  end

  def notify_users(users)
    users.each do |user|
      Resque.enqueue(Job::NotifyLocalUsers, user.id, @object.class.to_s, @object.id, @object.person_id)
    end
  end
  def socket_to_users(users)
    socket = @object.respond_to?(:socket_to_user)
    users.each do |user|
      if socket
        @object.socket_to_user(user)
      end
    end
  end
end
