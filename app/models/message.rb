class Message < ActiveRecord::Base
  include Diaspora::Federated::Base
  include Diaspora::Fields::Guid
  include Diaspora::Fields::Author

  belongs_to :conversation, touch: true

  delegate :name, to: :author, prefix: true

  # TODO: can be removed when messages are not relayed anymore
  alias_attribute :parent, :conversation

  validates :conversation, presence: true
  validates :text, presence: true
  validate :participant_of_parent_conversation

  def conversation_guid=(guid)
    self.conversation_id = Conversation.where(guid: guid).ids.first
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

  # @return [Array<Person>]
  def subscribers
    if author.local?
      conversation.participants
    else # for relaying, TODO: can be removed when messages are not relayed anymore
      conversation.participants.remote
    end
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
