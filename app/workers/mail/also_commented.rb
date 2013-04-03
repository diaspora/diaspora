module Workers
  module Mail
    class AlsoCommented < Base
      sidekiq_options queue: :mail

      def perform(recipient_id, sender_id, comment_id)
        if email = Notifier.also_commented(recipient_id, sender_id, comment_id)
          email.deliver
        end
      end
    end
  end
end

