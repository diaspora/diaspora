module Workers
  module Mail
    class Liked < Base
      sidekiq_options queue: :mail
      
      def perform(recipient_id, sender_id, like_id)
        Notifier.liked(recipient_id, sender_id, like_id).deliver
      end
    end
  end
end

