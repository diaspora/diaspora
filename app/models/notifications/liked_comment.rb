# frozen_string_literal: true

module Notifications
  class LikedComment < Notification
    def mail_job
      Mail::LikedCommentWorker
    end

    def popup_translation_key
      "notifications.liked_comment"
    end

    def deleted_translation_key
      "notifications.liked_comment_deleted"
    end
  end
end
