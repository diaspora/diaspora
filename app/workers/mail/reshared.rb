module Workers
  module Mail
    class Reshared < Base
      sidekiq_options queue: :mail
      
      def perform(recipient_id, sender_id, reshare_id)
        Notifier.reshared(recipient_id, sender_id, reshare_id).deliver
      end
    end
  end
end

