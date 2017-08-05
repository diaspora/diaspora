class CommentSignature < ApplicationRecord
  include Diaspora::Signature

  self.primary_key = :comment_id
  belongs_to :comment
  validates :comment, presence: true
end
