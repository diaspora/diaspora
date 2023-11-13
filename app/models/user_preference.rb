# frozen_string_literal: true

class UserPreference < ApplicationRecord
  belongs_to :user

  validate :must_be_valid_email_type

  VALID_EMAIL_TYPES =
    %w[
      someone_reported
      mentioned
      mentioned_in_comment
      comment_on_post
      private_message
      started_sharing
      also_commented
      liked
      liked_comment
      reshared
      contacts_birthday
    ].freeze

  def must_be_valid_email_type
    unless VALID_EMAIL_TYPES.include?(self.email_type)
      errors.add(:email_type, 'supplied mail type is not a valid or known email type')
    end
  end
end
