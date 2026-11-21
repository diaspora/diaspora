# frozen_string_literal: true

module Notifications
  class MentionedInComment < Notification
    include Notifications::Mentioned

    def popup_translation_key
      "notifications.mentioned_in_comment"
    end

    def deleted_translation_key
      "notifications.mentioned_in_comment_deleted"
    end
  end
end
