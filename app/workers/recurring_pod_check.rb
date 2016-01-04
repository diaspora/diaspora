module Workers
  class RecurringPodCheck < Base
    sidekiq_options queue: :maintenance

    def perform
      Pod.check_all!
    end
  end
end
