module Workers
  class RecurringPodCheck < Base
    sidekiq_options queue: :low

    def perform
      Pod.check_all!
    end
  end
end
