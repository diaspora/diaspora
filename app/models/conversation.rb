# frozen_string_literal: true

class Conversation < ApplicationRecord
  include Diaspora::Federated::Base
  include Diaspora::Fields::Guid
  include Diaspora::Fields::Author

  has_many :conversation_visibilities, dependent: :destroy
  has_many :participants, class_name: "Person", through: :conversation_visibilities, source: :person
  has_many :messages, -> { order("created_at ASC") }, inverse_of: :conversation

  validate :max_participants
  validate :local_recipients

  def max_participants
    errors.add(:max_participants, "too many participants") if participants.count > 20
  end

  def local_recipients
    recipients.each do |recipient|
      if recipient.local?
        unless recipient.owner.contacts.where(person_id: author.id).any? ||
            (author.owner && author.owner.podmin_account?)
          errors.add(:all_recipients, "recipient not allowed")
        end
      end
    end
  end

  accepts_nested_attributes_for :messages

  def recipients
    self.participants - [self.author]
  end

  def first_unread_message(user)
    if visibility = self.conversation_visibilities.where(:person_id => user.person.id).where('unread > 0').first
      self.messages.to_a[-visibility.unread]
    end
  end

  def set_read(user)
    visibility = conversation_visibilities.find_by(person_id: user.person.id)
    return unless visibility
    visibility.unread = 0
    visibility.save
  end

  def participant_handles
    participants.map(&:diaspora_handle).join(";")
  end

  def participant_handles=(handles)
    handles.split(";").each do |handle|
      participants << Person.find_or_fetch_by_identifier(handle)
    end
  end

  def last_author
    return unless @last_author.present? || messages.size > 0
    @last_author_id ||= messages.pluck(:author_id).last
    @last_author ||= Person.includes(:profile).find_by(id: @last_author_id)
  end

  def ordered_participants
    @ordered_participants ||= (messages.map(&:author).reverse + participants).uniq
  end

  def subject
    self[:subject].blank? ? I18n.t("conversations.new.subject_default") : self[:subject]
  end

  def subscribers
    recipients
  end
end
