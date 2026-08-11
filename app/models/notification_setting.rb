# frozen_string_literal: true

class NotificationSetting < ApplicationRecord
  self.inheritance_column = nil

  belongs_to :user

  validate :must_be_valid_type

  VALID_NOTIFICATION_TYPES =
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

  def must_be_valid_type
    unless VALID_NOTIFICATION_TYPES.include?(self.type)
      errors.add(:type, 'supplied type is not a valid or known notification type')
    end
  end
end
