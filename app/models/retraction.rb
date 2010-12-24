#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Retraction
  include ROXML
  include Diaspora::Webhooks

  xml_accessor :post_guid
  xml_accessor :diaspora_handle
  xml_accessor :type

  attr_accessor :person

  def self.for(object)
    retraction = self.new
    if object.is_a? User
      retraction.post_guid = object.person.guid
      retraction.type = object.person.class.to_s
    else
      retraction.post_guid = object.guid
      retraction.type = object.class.to_s
    end
    retraction.diaspora_handle = object.diaspora_handle
    retraction
  end

  def target
    @target ||= self.type.constantize.where(:guid => post_guid).first
  end

  def perform receiving_user_id
    Rails.logger.debug "Performing retraction for #{post_guid}"
    if self.target
      if  self.target.person != self.person
        Rails.logger.info("event=retraction status=abort reason='no post found authored by retractor' sender=#{person.diaspora_handle} post_id=#{post_guid}")
        return
      else
        Rails.logger.info("event=retraction status=complete type=#{self.type} guid=#{self.post_guid}")
        self.target.unsocket_from_uid receiving_user_id if target.respond_to? :unsocket_from_uid
        self.target.delete
      end
    end
  end
end
