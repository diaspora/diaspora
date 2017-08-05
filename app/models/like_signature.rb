class LikeSignature < ApplicationRecord
  include Diaspora::Signature

  self.primary_key = :like_id
  belongs_to :like
  validates :like, presence: true
end
