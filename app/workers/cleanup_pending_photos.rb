# frozen_string_literal: true

module Workers
  class CleanupPendingPhotos < Base
    sidekiq_options queue: :low

    def perform
      Photo.where(pending: true).where("created_at < ?", 1.day.ago).destroy_all
    end
  end
end
