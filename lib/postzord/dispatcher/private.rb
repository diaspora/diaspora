#   Copyright (c) 2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Postzord::Dispatcher::Private

  attr_reader :sender, :object, :xml, :subscribers

  # @param user [User] User dispatching the object in question
  # @param object [Object] The object to be sent to other Diaspora installations
  # @opt additional_subscribers [Array<Person>] Additional subscribers
  def initialize(user, object, opts={})
    @sender = user
    @object = object
    @xml = @object.to_diaspora_xml

    additional_subscribers = opts[:additional_subscribers] || []
    @subscribers = subscribers_from_object | [*additional_subscribers]
  end

  # @return [Object]
  def post(opts={})
    self.post_to_subscribers if @subscribers.present?
    self.deliver_to_services(opts[:url], opts[:services] || [])
    self.process_after_dispatch_hooks
    @object
  end

  protected

  # @return [Object]
  def process_after_dispatch_hooks
    @object.after_dispatch(@sender)
    @object
  end

  def post_to_subscribers
    remote_people, local_people = @subscribers.partition{ |person| person.owner_id.nil? }

    if @object.respond_to?(:relayable?) && @sender.owns?(@object.parent)
      self.socket_and_notify_local_users(local_people)
    else
      self.deliver_to_local(local_people)
    end

    self.deliver_to_remote(remote_people) unless @sender.username == 'diasporahq' #NOTE: 09/08/11 this is temporary (~3days max) till we fix fanout in federation
  end

  # @return [Array<Person>] Recipients of the object, minus any additional subscribers
  def subscribers_from_object
    @object.subscribers(@sender)
  end

  # @param local_people [Array<People>]
  # @return [ActiveRecord::Association<User>]
  def fetch_local_users(people)
    return if people.blank?
    user_ids = people.map{|x| x.owner_id }
    User.where(:id => user_ids)
  end

  # @param people [Array<Person>] Recipients of the post
  def deliver_to_remote(people)
    return if people.blank?
    Resque.enqueue(Job::HttpMulti, @sender.id, Base64.encode64(@object.to_diaspora_xml), people.map{|p| p.id}) 
  end

  # @param people [Array<Person>] Recipients of the post
  def deliver_to_local(people)
    return if people.blank? || @object.is_a?(Profile)
    if @object.is_a?(Post)
      batch_deliver_to_local(people)
    else
      people.each do |person|
        Rails.logger.info("event=push route=local sender=#{@sender.person.diaspora_handle} recipient=#{person.diaspora_handle} payload_type=#{@object.class}")
        Resque.enqueue(Job::Receive, person.owner_id, @xml, @sender.person.id)
      end
    end
  end

  # @param people [Array<Person>] Recipients of the post
  def batch_deliver_to_local(people)
    ids = people.map{ |p| p.owner_id }
    Resque.enqueue(Job::ReceiveLocalBatch, @object.id, ids)
    Rails.logger.info("event=push route=local sender=#{@sender.person.diaspora_handle} recipients=#{ids.join(',')} payload_type=#{@object.class}")
  end

  def deliver_to_hub
    Rails.logger.debug("event=post_to_service type=pubsub sender_handle=#{@sender.diaspora_handle}")
    Resque.enqueue(Job::PublishToHub, @sender.public_url)
  end

  # @param url [String]
  # @param services [Array<Service>]
  def deliver_to_services(url, services)
    if @object.respond_to?(:public) && @object.public
      deliver_to_hub
    end
    if @object.instance_of?(StatusMessage)
      services.each do |service|
        Resque.enqueue(Job::PostToService, service.id, @object.id, url)
      end
    end
  end

  # @param services [Array<User>]
  def socket_and_notify_users(users)
    notify_users(users)
    socket_to_users(users)
  end

  # @param local_people [Array<People>]
  def socket_and_notify_local_users(local_people)
    local_users = fetch_local_users(local_people)
    self.notify_users(local_users)
    local_users << @sender if @object.author.local?
    self.socket_to_users(local_users)
  end

  # @param services [Array<User>]
  def notify_users(users)
    Resque.enqueue(Job::NotifyLocalUsers, users.map{|u| u.id}, @object.class.to_s, @object.id, @object.author.id)
  end

  # @param services [Array<User>]
  def socket_to_users(users)
    return unless @object.respond_to?(:socket_to_user)
    users.each do |user|
      @object.socket_to_user(user)
    end
  end
end
