class Message < ActiveRecord::Base
  include Diaspora::Federated::Base
  include Diaspora::Guid
  include Diaspora::Relayable

  belongs_to :author, class_name: "Person"
  belongs_to :conversation, touch: true

  delegate :diaspora_handle, to: :author
  delegate :name, to: :author, prefix: true

  alias_attribute :parent, :conversation

  validates :text, :presence => true
  validate :participant_of_parent_conversation

  def diaspora_handle=(nh)
    self.author = Person.find_or_fetch_by_identifier(nh)
  end

  def conversation_guid=(guid)
    if cnv = Conversation.find_by_guid(guid)
      self.conversation_id = cnv.id
    end
  end

  def increase_unread(user)
    if vis = ConversationVisibility.where(:conversation_id => self.conversation_id, :person_id => user.person.id).first
      vis.unread += 1
      vis.save
    end
  end

  def message
    @message ||= Diaspora::MessageRenderer.new text
  end

  private

  def participant_of_parent_conversation
    if conversation && !conversation.participants.include?(author)
      errors[:base] << "Author is not participating in the conversation"
    else
      true
    end
  end
end
