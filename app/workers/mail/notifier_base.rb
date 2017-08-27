# frozen_string_literal: true

module Workers
  module Mail
    class NotifierBase < Base
      sidekiq_options queue: :low

      def perform(*args)
        Notifier.send_notification(self.class.name.gsub("Workers::Mail::", "").underscore, *args).deliver_now
      end
    end
  end
end
