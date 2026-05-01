# frozen_string_literal: true

module Mail
  class NotifierBaseWorker < ::BaseWorker
    sidekiq_options queue: :low

    def perform(*args)
      Notifier.send_notification(self.class.name.demodulize.underscore.sub(/_worker\z/, ""), *args).deliver_now
    end
  end
end
