class Message < ActiveRecord::Base
  include ROXML

  include Diaspora::Guid
  include Diaspora::Webhooks
  include Diaspora::Relayable

  xml_attr :text
  xml_attr :created_at
  xml_reader :diaspora_handle
  xml_reader :conversation_guid

  belongs_to :author, :class_name => 'Person'
  belongs_to :conversation

  after_initialize do
    #sign comment as commenter
    self.author_signature = self.sign_with_key(self.author.owner.encryption_key) if self.author.owner

    if !self.parent.blank? &&  self.parent.author.person.owns?(self.parent)
      #sign comment as post owner
      self.parent_author_signature = self.sign_with_key( self.parent.author.owner.encryption_key) if self.parent.author.owner
    end
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
end
