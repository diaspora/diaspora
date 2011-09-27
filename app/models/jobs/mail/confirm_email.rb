module Jobs
  module Mail
    class ConfirmEmail < Base
      @queue = :mail
      def self.perform(user_id)
        Notifier.confirm_email(user_id).deliver
      end
    end
  end
end
