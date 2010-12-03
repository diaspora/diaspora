module Jobs
  class MailRequestReceived
    @queue = :mail
    def self.perform(recipient_id, sender_id)
      Notifier.new_request(recipient_id, sender_id).deliver
    end
  end
end

