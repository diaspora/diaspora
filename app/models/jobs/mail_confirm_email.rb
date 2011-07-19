module Job
  class MailConfirmEmail < Base
    @queue = :mail
    def self.perform_delegate(user_id)
      Notifier.confirm_email(user_id).deliver
    end
  end
end