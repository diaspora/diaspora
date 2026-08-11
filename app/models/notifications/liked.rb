# frozen_string_literal: true

module Notifications
  class Liked < Notification
    def popup_translation_key
      "notifications.liked"
    end

    def deleted_translation_key
      "notifications.liked_post_deleted"
    end
  end
end
