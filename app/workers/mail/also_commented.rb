module Workers
  module Mail
    class AlsoCommented < Base
      sidekiq_options queue: :low

      def perform(recipient_id, sender_id, comment_id)
        if email = Notifier.also_commented(recipient_id, sender_id, comment_id)
          email.deliver_now
        end
      end
    end
  end
end

