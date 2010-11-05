#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Retraction
  include ROXML
  include Diaspora::Webhooks

  xml_accessor :post_id
  xml_accessor :diaspora_handle
  xml_accessor :type

  attr_accessor :person

  def self.for(object)
    retraction = self.new
    if object.is_a? User
      retraction.post_id = object.person.id
      retraction.type = object.person.class.to_s
    else
      retraction.post_id = object.id
      retraction.type = object.class.to_s
    end
    retraction.diaspora_handle = object.diaspora_handle 
    retraction
  end

  def perform receiving_user_id
    Rails.logger.debug "Performing retraction for #{post_id}"
    if self.type.constantize.find_by_id(post_id) 
      unless Post.first(:diaspora_handle => person.diaspora_handle, :id => post_id) 
        raise "#{person.inspect} is trying to retract a post they do not own"
      end

      begin
        Rails.logger.debug("Retracting #{self.type} id: #{self.post_id}")
        target = self.type.constantize.first(:id => self.post_id)
        target.unsocket_from_uid receiving_user_id if target.respond_to? :unsocket_from_uid
        target.delete
      rescue NameError
        Rails.logger.info("Retraction for unknown type recieved.")
      end
    end
  end
end
