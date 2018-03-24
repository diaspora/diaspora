# frozen_string_literal: true

module Workers
  class RecheckScheduledPods < Base
    sidekiq_options queue: :low

    def perform
      Pod.check_scheduled!
    end
  end
end
