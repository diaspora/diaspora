# frozen_string_literal: true

class Message < ApplicationRecord
  include Diaspora::Federated::Base
  include Diaspora::Fields::Guid
  include Diaspora::Fields::Author

  include Reference::Source

  belongs_to :conversation, touch: true

  delegate :name, to: :author, prefix: true

  validates :text, presence: true
  validate :participant_of_parent_conversation

  def conversation_guid=(guid)
    self.conversation_id = Conversation.where(guid: guid).ids.first
  end

  def increase_unread(user)
    vis = ConversationVisibility.find_by(conversation_id: conversation_id, person_id: user.person.id)
    return unless vis
    vis.unread += 1
    vis.save
  end

  def message
    @message ||= Diaspora::MessageRenderer.new text
  end

  # @return [Array<Person>]
  def subscribers
    conversation.participants
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
