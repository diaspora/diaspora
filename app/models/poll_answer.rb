# frozen_string_literal: true

class PollAnswer < ApplicationRecord
  include Diaspora::Federated::Base
  include Diaspora::Fields::Guid

  belongs_to :poll
  has_many :poll_participations

  validates :answer, presence: true

  self.include_root_in_json = false
end
