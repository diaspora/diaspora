module Jobs
  module Mail
    class Reshared < Base
      @queue = :mail
      def self.perform(recipient_id, sender_id, reshare_id)
        Notifier.reshared(recipient_id, sender_id, reshare_id).deliver
      end
    end
  end
end

