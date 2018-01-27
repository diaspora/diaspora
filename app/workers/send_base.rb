# frozen_string_literal: true

module Workers
  class SendBase < Base
    sidekiq_options queue: :medium, retry: 0

    MAX_RETRIES = AppConfig.environment.sidekiq.retry.get.to_i

    protected

    def schedule_retry(retry_count, sender_id, obj_str, failed_urls)
      if retry_count < (obj_str.start_with?("Contact") ? MAX_RETRIES + 10 : MAX_RETRIES)
        yield(seconds_to_delay(retry_count), retry_count)
      else
        logger.warn "status=abandon sender=#{sender_id} obj=#{obj_str} failed_urls='[#{failed_urls.join(', ')}]'"
        raise MaxRetriesReached
      end
    end

    private

    # based on Sidekiq::Middleware::Server::RetryJobs#seconds_to_delay
    def seconds_to_delay(count)
      ((count + 3)**4) + (rand(30) * (count + 1))
    end

    # send job to the dead job queue
    class MaxRetriesReached < RuntimeError
    end
  end
end
