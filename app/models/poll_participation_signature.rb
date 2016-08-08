class PollParticipationSignature < ActiveRecord::Base
  include Diaspora::Signature

  self.primary_key = :poll_participation_id
  belongs_to :poll_participation
  validates :poll_participation, presence: true
end
