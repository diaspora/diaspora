module Jobs
  module Mail
    class AlsoCommented < Base
      @queue = :mail
      def self.perform(recipient_id, sender_id, comment_id)
        if email = Notifier.also_commented(recipient_id, sender_id, comment_id)
          email.deliver
        end
      end
    end
  end
end

