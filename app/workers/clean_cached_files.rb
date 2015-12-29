module Workers
  class CleanCachedFiles < Base
    include Sidetiq::Schedulable

    sidekiq_options queue: :low

    recurrence { daily }

    def perform
      CarrierWave.clean_cached_files!
    end
  end 
end
