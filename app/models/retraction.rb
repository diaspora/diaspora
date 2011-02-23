#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Retraction
  include ROXML
  include Diaspora::Webhooks

  xml_accessor :post_guid
  xml_accessor :diaspora_handle
  xml_accessor :type

  attr_accessor :person, :object, :subscribers

  def subscribers(user)
    unless self.type == 'Person'
      @subscribers ||= self.object.subscribers(user)
    else
      raise 'HAX: you must set the subscribers manaully before unfriending' if @subscribers.nil?
      @subscribers
    end
  end

  def self.for(object)
    retraction = self.new
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

  def perform receiving_user
    Rails.logger.debug "Performing retraction for #{post_guid}"
    self.target.unsocket_from_user receiving_user if target.respond_to? :unsocket_from_user
    self.target.destroy
    target.post_visibilities.delete_all
    Rails.logger.info("event=retraction status=complete type=#{self.type} guid=#{self.post_guid}")
  end

  def receive(user, person)
    if self.type == 'Person'
      unless self.person.guid.to_s == self.post_guid.to_s
        Rails.logger.info("event=receive status=abort reason='sender is not the person he is trying to retract' recipient=#{self.diaspora_handle} sender=#{self.person.diaspora_handle} payload_type=#{self.class} retraction_type=person")
        return
      end
      user.disconnected_by(self.target)
    elsif self.target.nil? || self.target.person != self.person
      Rails.logger.info("event=retraction status=abort reason='no post found authored by retractor' sender=#{person.diaspora_handle} post_guid=#{post_guid}")
    else
      self.perform(user)
    end
    self
  end
end
