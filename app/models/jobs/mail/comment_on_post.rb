module Jobs
  module Mail
    class CommentOnPost < Base
      @queue = :mail
      def self.perform(recipient_id, sender_id, comment_id)
        Notifier.comment_on_post(recipient_id, sender_id, comment_id).deliver
      end
    end
  end
end

