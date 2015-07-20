module Workers
  module Mail
    class ConfirmEmail < Base
      sidekiq_options queue: :mail
      
      def perform(user_id)
        Notifier.confirm_email(user_id).deliver_now
      end
    end
  end
end
