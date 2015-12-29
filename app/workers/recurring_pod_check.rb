
module Workers
  class RecurringPodCheck < Base
    include Sidetiq::Schedulable

    sidekiq_options queue: :low

    recurrence { daily }

    def perform
      Pod.check_all!
    end
  end
end
