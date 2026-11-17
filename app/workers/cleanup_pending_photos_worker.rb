# frozen_string_literal: true

class CleanupPendingPhotosWorker < BaseWorker
  sidekiq_options queue: :low

  def perform
    Photo.where(pending: true).where(created_at: ...1.day.ago).destroy_all
  end
end
