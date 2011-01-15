module Jobs
  class MailCommentOnPost
    extend ResqueJobLogging
    @queue = :mail
    def self.perform(recipient_id, sender_id, comment_id)
      Notifier.comment_on_post(recipient_id, sender_id, comment_id).deliver
    end
  end
end

