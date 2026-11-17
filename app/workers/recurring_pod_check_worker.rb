# frozen_string_literal: true

class RecurringPodCheckWorker < BaseWorker
  sidekiq_options queue: :low

  def perform
    Pod.check_all!
  end
end
