# frozen_string_literal: true

module Notifications
  class MentionedInPost < Notification
    include Notifications::Mentioned

    def popup_translation_key
      "notifications.mentioned"
    end

    def deleted_translation_key
      "notifications.mentioned_deleted"
    end
  end
end
