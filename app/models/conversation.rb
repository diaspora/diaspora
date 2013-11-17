class Conversation < ActiveRecord::Base
  include Diaspora::Federated::Base
  include Diaspora::Guid

  xml_attr :subject
  xml_attr :created_at
  xml_attr :messages, :as => [Message]
  xml_reader :diaspora_handle
  xml_reader :participant_handles

  has_many :conversation_visibilities, :dependent => :destroy
  has_many :participants, :class_name => 'Person', :through => :conversation_visibilities, :source => :person
  has_many :messages, -> { order('created_at ASC') }

  belongs_to :author, :class_name => 'Person'

  validate :max_participants

  def max_participants
    errors.add(:max_participants, "too many participants") if participants.count > 20
  end

  accepts_nested_attributes_for :messages

  def recipients
    self.participants - [self.author]
  end

  def diaspora_handle
    self.author.diaspora_handle
  end

  def diaspora_handle= nh
    self.author = Webfinger.new(nh).fetch
  end

  def first_unread_message(user)
    if visibility = self.conversation_visibilities.where(:person_id => user.person.id).where('unread > 0').first
      self.messages.to_a[-visibility.unread]
    end
  end

  def public?
    false
  end

  def participant_handles
    self.participants.map{|p| p.diaspora_handle}.join(";")
  end
  def participant_handles= handles
    handles.split(';').each do |handle|
      self.participants << Webfinger.new(handle).fetch
    end
  end

  def last_author
    return unless @last_author.present? || self.messages.size > 0
    @last_author_id ||= self.messages.pluck(:author_id).last
    @last_author ||= Person.includes(:profile).where(id: @last_author_id).first
  end

  def subject
    self[:subject].blank? ? "no subject" : self[:subject]
  end

  def subscribers(user)
    self.recipients
  end

  def receive(user, person)
    cnv = Conversation.find_or_create_by(self.attributes)

    self.participants.each do |participant|
      ConversationVisibility.find_or_create_by(conversation_id: cnv.id, person_id: participant.id)
    end

    self.messages.each do |msg|
      msg.conversation_id = cnv.id
      received_msg = msg.receive(user, person)
      Notification.notify(user, received_msg, person) if msg.respond_to?(:notification_type)
    end
  end
end
