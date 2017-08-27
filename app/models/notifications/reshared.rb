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

    def self.notify(reshare, _recipient_user_ids)
      return unless reshare.root.present? && reshare.root.author.local?

      actor = reshare.author
      concatenate_or_create(reshare.root.author.owner, reshare.root, actor).try(:email_the_user, reshare, actor)
    end
  end
end
