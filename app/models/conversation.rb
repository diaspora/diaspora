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

  def author
    self.messages.first.author
  end

  def recipients
    self.participants - [self.author]
  end

  def participant_handles
    self.participants.map{|p| p.diaspora_handle}.join(";")
  end

  def participant_handles= handles
    handles.split(';').each do |handle|
      self.participants << Webfinger.new(handle).fetch
    end
  end
  def subscribers(user)
    self.recipients
  end
  
  def receive(user, person)
    cnv = Conversation.find_or_create_by_guid(self.attributes)
    self.messages.each do |msg|
      msg.conversation_id = cnv.id
      msg.receive(user, person)
    end
    self.participants.each do |participant|
      ConversationVisibility.create(:conversation_id => cnv.id, :person_id => participant.id)
    end
  end
end
