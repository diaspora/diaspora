module Workers
  module Mail
    class CommentOnPost < Base
      sidekiq_options queue: :low

      def perform(recipient_id, sender_id, comment_id)
        Notifier.comment_on_post(recipient_id, sender_id, comment_id).deliver_now
      end
    end
  end
end

