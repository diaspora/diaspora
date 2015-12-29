module Workers
  module Mail
    class Liked < Base
      sidekiq_options queue: :low

      def perform(recipient_id, sender_id, like_id)
        Notifier.liked(recipient_id, sender_id, like_id).deliver_now
      rescue ActiveRecord::RecordNotFound => e
        logger.warn("failed to send liked notification mail: #{e.message}")
        raise e unless e.message.start_with?("Couldn't find Like with")
      end
    end
  end
end

