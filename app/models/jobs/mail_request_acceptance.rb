module Jobs
  class MailRequestAcceptance
    @queue = :mail
    def self.perform(recipient_id, sender_id)
      Notifier.request_accepted(recipient_id, sender_id).deliver
    end
  end
end

