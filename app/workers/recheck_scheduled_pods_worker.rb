# frozen_string_literal: true

class RecheckScheduledPodsWorker < BaseWorker
  sidekiq_options queue: :low

  def perform
    Pod.check_scheduled!
  end
end
