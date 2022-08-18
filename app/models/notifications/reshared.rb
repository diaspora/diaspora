# frozen_string_literal: true

module Notifications
  class Reshared < Notification
    def mail_job
      Workers::Mail::Reshared
    end

    def popup_translation_key
      "notifications.reshared"
    end

    def deleted_translation_key
      "notifications.reshared_post_deleted"
    end
  end
end
