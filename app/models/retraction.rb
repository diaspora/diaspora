#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Retraction
  include ROXML
  include Diaspora::Webhooks

  xml_accessor :post_id
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
      retraction.post_id = object.person.id
      retraction.type = object.person.class.to_s
    else
      retraction.post_id = object.id
      retraction.type = object.class.to_s
      retraction.object = object
    end
    retraction.diaspora_handle = object.diaspora_handle 
    retraction
  end

  def perform(receiving_user)
    Rails.logger.debug "Performing retraction for #{post_id}"
    if self.type.constantize.find_by_id(post_id) 
      unless Post.first(:diaspora_handle => person.diaspora_handle, :id => post_id) 
        Rails.logger.info("event=retraction status=abort reason='no post found authored by retractor' sender=#{person.diaspora_handle} post_id=#{post_id}")
        return 
      end

      begin
        Rails.logger.debug("Retracting #{self.type} id: #{self.post_id}")
        target = self.type.constantize.first(:id => self.post_id)
        target.unsocket_from_uid(receiving_user, self) if target.respond_to? :unsocket_from_uid
        target.delete
      rescue NameError
        Rails.logger.info("event=retraction status=abort reason='unknown type'")
      end
    end
  end

  def receive(user, person)
    if self.type == 'Person'
      unless self.person.id.to_s == self.post_id.to_s
        Rails.logger.info("event=receive status=abort reason='sender is not the person he is trying to retract' recipient=#{self.diaspora_handle} sender=#{self.person.diaspora_handle} payload_type=#{self.class} retraction_type=person")
        return
      end
      user.disconnected_by(user.visible_person_by_id(self.post_id))
    else
      self.perform(user)
      aspects = user.aspects_with_person(self.person)
      aspects.each do |aspect|
        aspect.post_ids.delete(self.post_id.to_id)
        aspect.save
      end
    end
    self
  end
end
