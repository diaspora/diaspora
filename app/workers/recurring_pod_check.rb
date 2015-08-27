
module Workers
  class RecurringPodCheck < Base
    include Sidetiq::Schedulable

    sidekiq_options queue: :maintenance

    recurrence { daily }

    def perform
      Pod.check_all!
    end
  end
end
