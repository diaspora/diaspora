# frozen_string_literal: true

class CleanCachedFilesWorker < BaseWorker
  sidekiq_options queue: :low

  def perform
    CarrierWave.clean_cached_files!
  end
end
