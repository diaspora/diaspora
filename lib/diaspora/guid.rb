#implicitly requires roxml

module Diaspora::Guid
  # Creates a before_create callback which calls #set_guid and makes the guid serialize in to_xml
  def self.included(model)
    model.class_eval do
      after_initialize :set_guid
      xml_attr :guid
      validates :guid, :uniqueness => true

    end
  end

  # @return [String] The model's guid.
  def set_guid
    self.guid = UUID.generate :compact if self.guid.blank?
  end
end
