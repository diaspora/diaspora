class Conversation < ActiveRecord::Base
  include ROXML
  include Diaspora::Guid
  include Diaspora::Webhooks

  xml_attr :subject
  xml_attr :messages, :as => [Message]
  xml_attr :created_at
  xml_reader :participant_handles

  has_many :conversation_visibilities
  has_many :participants, :class_name => 'Person', :through => :conversation_visibilities, :source => :person
  has_many :messages, :order => 'created_at ASC'

  def recipients
    self.participants - [self.author]
  end

  def participant_handles
    self.participants.map{|p| p.diaspora_handle}.join(";")
  end
end
