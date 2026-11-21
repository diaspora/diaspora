# frozen_string_literal: true

module Notifications
  class CommentOnPost < Notification
    include Notifications::Commented

    def popup_translation_key
      "notifications.comment_on_post"
    end
  end
end
