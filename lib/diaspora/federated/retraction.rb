#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.
class Retraction
  include Diaspora::Federated::Base

  xml_accessor :post_guid
  xml_accessor :diaspora_handle
  xml_accessor :type

  attr_accessor :person, :object, :subscribers

  def initialize(data, subscribers)
    @data = data
    @subscribers = subscribers
  end

  def subscribers
    unless self.type == 'Person'
      @subscribers ||= object.subscribers
      @subscribers -= self.object.resharers unless self.object.is_a?(Photo)
      @subscribers
    else
      raise 'HAX: you must set the subscribers manaully before unfriending' if @subscribers.nil?
      @subscribers
    end
  end

  def self.for(object)
    retraction = new({}, [])
    if object.is_a? User
      retraction.post_guid = object.person.guid
      retraction.type = object.person.class.to_s
    else
      retraction.post_guid = object.guid
      retraction.type = object.class.to_s
      retraction.object = object
    end
    retraction.diaspora_handle = object.diaspora_handle
    retraction
  end

  def target
    @target ||= self.type.constantize.where(:guid => post_guid).first
  end

  def defer_dispatch(user)
    Workers::DeferredRetraction.perform_async(user.id, data, subscribers.map(&:id))
  end

  def perform receiving_user
    logger.debug "Performing retraction for #{post_guid}"

    self.target.destroy if self.target
    logger.info "event=retraction status=complete type=#{type} guid=#{post_guid}"
  end

  def correct_authorship?
    if target.respond_to?(:relayable?) && target.relayable?
      [target.author, target.parent.author].include?(person)
    else
      target.author == person
    end
  end
end
