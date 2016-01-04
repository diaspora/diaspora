module Workers
  class CleanCachedFiles < Base
    sidekiq_options queue: :maintenance

    def perform
      CarrierWave.clean_cached_files!
    end
  end
end
