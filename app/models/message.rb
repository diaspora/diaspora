class Message < ActiveRecord::Base
  include ROXML
  include Diaspora::Guid
  include Diaspora::Webhooks

  xml_attr :text
  xml_attr :created_at

  belongs_to :author, :class_name => 'Person'
  belongs_to :conversation

end
