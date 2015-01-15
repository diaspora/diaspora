class Conversation < ActiveRecord::Base
  include Diaspora::Federated::Base
  include Diaspora::Guid

  xml_attr :subject
  xml_attr :created_at
  xml_attr :messages, as: [Message]
  xml_reader :diaspora_handle
  xml_reader :participant_handles

  has_many :conversation_visibilities, dependent: :destroy
  has_many :participants, class_name: 'Person', through: :conversation_visibilities, source: :person
  has_many :messages, -> { order('created_at ASC') }

  belongs_to :author, class_name: 'Person'

  validate :max_participants
  validate :local_recipients

  def max_participants
    errors.add(:max_participants, 'too many participants') if participants.count > 20
  end

  def local_recipients
    recipients.each do |recipient|
      if recipient.local?
        if recipient.owner.contacts.where(person_id: author.id).count == 0
          errors.add(:all_recipients, 'recipient not allowed')
        end
      end
    end
  end

  accepts_nested_attributes_for :messages

  def recipients
    participants - [author]
  end

  delegate :diaspora_handle, to: :author

  def diaspora_handle=(nh)
    self.author = Webfinger.new(nh).fetch
  end

  def first_unread_message(user)
    if visibility = conversation_visibilities.where(person_id: user.person.id).where('unread > 0').first
      messages.to_a[-visibility.unread]
    end
  end

  def public?
    false
  end

  def participant_handles
    participants.map(&:diaspora_handle).join(';')
  end

  def participant_handles=(handles)
    handles.split(';').each do |handle|
      participants << Webfinger.new(handle).fetch
    end
  end

  def last_author
    return unless @last_author.present? || messages.size > 0
    @last_author_id ||= messages.pluck(:author_id).last
    @last_author ||= Person.includes(:profile).where(id: @last_author_id).first
  end

  def subject
    self[:subject].blank? ? 'no subject' : self[:subject]
  end

  def subscribers(_user)
    recipients
  end

  def receive(user, person)
    cnv = Conversation.find_or_create_by!(attributes)

    participants.each do |participant|
      ConversationVisibility.find_or_create_by(conversation_id: cnv.id, person_id: participant.id)
    end

    messages.each do |msg|
      msg.conversation_id = cnv.id
      received_msg = msg.receive(user, person)
      Notification.notify(user, received_msg, person) if msg.respond_to?(:notification_type)
    end
  end
end
