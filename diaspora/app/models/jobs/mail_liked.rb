module Job
  class MailLiked < Base
    @queue = :mail
    def self.perform(recipient_id, sender_id, like_id)
      Notifier.liked(recipient_id, sender_id, like_id).deliver
    end
  end
end

