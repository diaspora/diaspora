class Poll < ActiveRecord::Base
  include Diaspora::Federated::Base
  include Diaspora::Guid
  attr_accessible :question, :poll_answers
  belongs_to :status_message
  has_many :poll_answers
  has_many :poll_participations

  xml_attr :question
  xml_attr :poll_answers, :as => [PollAnswer]

  #forward some requests to status message, because a poll is just attached to a status message and is not sharable itself
  delegate :author, :author_id, :public?, :subscribers, to: :status_message

  validate :enough_poll_answers

  def enough_poll_answers
    errors.add(:poll_answers, I18n.t("activerecord.errors.models.poll.attributes.poll_answers.not_enough_poll_answers")) if poll_answers.size < 2
  end

end
