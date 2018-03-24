# frozen_string_literal: true

module Notifications
  module Commented
    extend ActiveSupport::Concern

    def deleted_translation_key
      "notifications.also_commented_deleted"
    end

    module ClassMethods
      def mention_notification_exists?(comment, recipient_person)
        Notifications::MentionedInComment.exists?(target: comment.mentions.where(person: recipient_person))
      end
    end
  end
end
