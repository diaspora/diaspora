class Poll < ActiveRecord::Base
  include Diaspora::Federated::Base
  include Diaspora::Guid

  belongs_to :status_message
  has_many :poll_answers
  has_many :poll_participations

  xml_attr :question
  xml_attr :poll_answers, :as => [PollAnswer]

  #forward some requests to status message, because a poll is just attached to a status message and is not sharable itself
  delegate :author, :author_id, :diaspora_handle, :public?, :subscribers, to: :status_message

  validate :enough_poll_answers
  validates :question, presence: true

  self.include_root_in_json = false

  def enough_poll_answers
    errors.add(:poll_answers, I18n.t("activerecord.errors.models.poll.attributes.poll_answers.not_enough_poll_answers")) if poll_answers.size < 2
  end

  def as_json(options={})
    {
      :poll_id => self.id,
      :post_id => self.status_message.id,
      :question => self.question,
      :poll_answers => self.poll_answers,
      :participation_count => self.participation_count,
    }
  end

  def participation_count
    poll_answers.sum("vote_count")
  end

  def already_participated?(user)
    poll_participations.where(:author_id => user.person.id).present?
  end
end
