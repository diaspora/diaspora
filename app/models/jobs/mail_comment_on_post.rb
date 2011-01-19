module Job
  class MailCommentOnPost < Base
    @queue = :mail
    def self.perform_delegate(recipient_id, sender_id, comment_id)
      Notifier.comment_on_post(recipient_id, sender_id, comment_id).deliver
    end
  end
end

