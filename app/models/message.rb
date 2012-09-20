class NotVisibleError < RuntimeError; end
class Message < ActiveRecord::Base
  include Diaspora::Federated::Base
  include Diaspora::Guid
  include Diaspora::Relayable

  xml_attr :text
  xml_attr :created_at
  xml_reader :diaspora_handle
  xml_reader :conversation_guid

  belongs_to :author, :class_name => 'Person'
  belongs_to :conversation, :touch => true
  
  delegate :name, to: :author, prefix: true

  validates :text, :presence => true
  validate :participant_of_parent_conversation

  after_create do
    #sign comment as commenter
    self.author_signature = self.sign_with_key(self.author.owner.encryption_key) if self.author.owner

    if self.author.owns?(self.parent)
      #sign comment as post owner
      self.parent_author_signature = self.sign_with_key(self.parent.author.owner.encryption_key) if self.parent.author.owner
    end
    self.save!
    self
  end

  def diaspora_handle
    self.author.diaspora_handle
  end

  def diaspora_handle= nh
    self.author = Webfinger.new(nh).fetch
  end

  def conversation_guid
    self.conversation.guid
  end

  def conversation_guid= guid
    if cnv = Conversation.find_by_guid(guid)
      self.conversation_id = cnv.id
    end
  end

  def parent_class
    Conversation
  end

  def parent
    self.conversation
  end

  def parent= parent
    self.conversation = parent
  end

  def after_receive(user, person)
    if vis = ConversationVisibility.where(:conversation_id => self.conversation_id, :person_id => user.person.id).first
      vis.unread += 1
      vis.save
      self
    else
      raise NotVisibleError.new("User #{user.id} with person #{user.person.id} is not allowed to see conversation #{conversation.id}!")
    end
  end

  def notification_type(user, person)
    Notifications::PrivateMessage unless user.person == person
  end

  def formatted_message(opts={})
    opts[:plain_text] ? self.text: ERB::Util.h(self.text)
  end

  private
  def participant_of_parent_conversation
    if self.parent && !self.parent.participants.include?(self.author)
      errors[:base] << "Author is not participating in the conversation"
    else
      true
    end
  end
end
