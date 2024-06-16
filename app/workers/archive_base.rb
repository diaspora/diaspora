# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Workers
  class ArchiveBase < Base
    sidekiq_options queue: :low

    include Diaspora::Logging

    def perform(*args)
      if currently_running_archive_jobs >= AppConfig.settings.archive_jobs_concurrency.to_i
        logger.info "Already the maximum number of parallel archive jobs running, " \
                    "scheduling #{self.class}:#{args} in 5 minutes."
        self.class.perform_in(5.minutes + rand(30), *args)
      else
        perform_archive_job(*args)
      end
    end

    private

    def perform_archive_job(_args)
      raise NotImplementedError, "You must override perform_archive_job"
    end

    def currently_running_archive_jobs
      Sidekiq::Workers.new.count do |process_id, thread_id, work|
        !(Process.pid.to_s == process_id.split(":")[1] && Thread.current.object_id.to_s(36) == thread_id) &&
          ArchiveBase.subclasses.map(&:to_s).include?(work["payload"]["class"])
      end
    rescue Redis::CannotConnectError
      # If code gets to this point and there is no Redis conenction, we're
      # running in a Test environment and have not mocked Sidekiq::Workers, so
      # we're not testing the concurrency-limiting behavior.
      # There is no way a production pod will run into this code, as diaspora*
      # refuses to start without redis.
      0
    end
  end
end
