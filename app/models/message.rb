class Message < ActiveRecord::Base
  include ROXML
  include Diaspora::Guid
  include Diaspora::Webhooks

  xml_attr :text
  xml_attr :created_at
  xml_reader :diaspora_handle
  xml_reader :conversation_guid

  belongs_to :author, :class_name => 'Person'
  belongs_to :conversation

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

  def receive(user, person)
    Message.find_or_create_by_guid(self.attributes)
  end

  def subscribers(user)
    if self.conversation.author == user.person
      p = self.conversation.subscribers(user)
    else
      p = self.conversation.author
    end
  end
end
