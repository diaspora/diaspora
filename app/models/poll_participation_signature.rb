# frozen_string_literal: true

class PollParticipationSignature < ApplicationRecord
  include Diaspora::Signature

  self.primary_key = :poll_participation_id
  belongs_to :poll_participation
end
