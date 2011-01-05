module Jobs
  class MailCommentOnPost
    extend ResqueJobLogging
    @queue = :mail
    def self.perform(recipient_id, sender_id, comment)
      Notifier.comment_on_post(recipient_id, sender_id, comment).deliver
    end
  end
end

