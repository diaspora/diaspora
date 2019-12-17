# frozen_string_literal: true

class Poll < ApplicationRecord
  include Diaspora::Federated::Base
  include Diaspora::Fields::Guid
  include Diaspora::Federated::Fetchable

  belongs_to :status_message
  has_many :poll_answers, -> { order "id ASC" }, dependent: :destroy
  has_many :poll_participations, dependent: :destroy
  has_one :author, through: :status_message

  #forward some requests to status message, because a poll is just attached to a status message and is not sharable itself
  delegate :author_id, :diaspora_handle, :public?, :subscribers, to: :status_message

  validate :enough_poll_answers
  validates :question, presence: true

  scope :all_public, -> { joins(:status_message).where(posts: {public: true}) }

  self.include_root_in_json = false

  def enough_poll_answers
    errors.add(:poll_answers, I18n.t("activerecord.errors.models.poll.attributes.poll_answers.not_enough_poll_answers")) if poll_answers.size < 2
  end

  def as_json(options={})
    {
      poll_id:             id,
      post_id:             status_message.id,
      question:            question,
      poll_answers:        poll_answers,
      participation_count: participation_count
    }
  end

  def participation_answer(user)
    poll_participations.find_by(author_id: user.person.id)
  end

  def participation_count
    poll_answers.sum("vote_count")
  end
end
