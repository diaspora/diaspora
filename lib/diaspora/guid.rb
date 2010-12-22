module Diaspora::Guid
  def self.included(model)
    model.class_eval do
      before_create :set_guid
      xml_attr :guid
    end
  end
  def set_guid
    self.guid ||= ActiveSupport::SecureRandom.hex(8)
  end
end
