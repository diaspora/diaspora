# frozen_string_literal: true

module Workers
  class CleanCachedFiles < Base
    sidekiq_options queue: :low

    def perform
      CarrierWave.clean_cached_files!
    end
  end
end
