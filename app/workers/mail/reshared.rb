module Workers
  module Mail
    class Reshared < Base
      sidekiq_options queue: :low
      
      def perform(recipient_id, sender_id, reshare_id)
        Notifier.reshared(recipient_id, sender_id, reshare_id).deliver_now
      end
    end
  end
end

