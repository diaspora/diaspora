module Job
  class MailAlsoCommented < Base
    @queue = :mail
    def self.perform(recipient_id, sender_id, comment_id)
      Notifier.also_commented(recipient_id, sender_id, comment_id).deliver
    end
  end
end

