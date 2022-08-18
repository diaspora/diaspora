# frozen_string_literal: true

module Notifications
  class StartedSharing < Notification
    def mail_job
      Workers::Mail::StartedSharing
    end

    def popup_translation_key
      "notifications.started_sharing"
    end

    def contact
      recipient.contact_for(target)
    end
  end
end
