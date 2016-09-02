module Workers
  module Mail
    class CsrfTokenFail < Base
      sidekiq_options queue: :low

      def perform(user_id)
        Notifier.csrf_token_fail(user_id).deliver_now
      end
    end
  end
end
