# frozen_string_literal: true

require "sidekiq_middlewares"
require "sidekiq/middleware/i18n"

# Single process-mode
if AppConfig.environment.single_process_mode? && !Rails.env.test?
  if Rails.env.production?
    warn "WARNING: You are running Diaspora in production without Sidekiq"
    warn "         workers turned on.  Please set single_process_mode to false in"
    warn "         config/diaspora.toml."
  end
  require "sidekiq/testing/inline"
end

Sidekiq.configure_server do |config|
  config.redis = AppConfig.get_redis_options

  config.server_middleware do |chain|
    chain.add SidekiqMiddlewares::CleanAndShortBacktraces
  end

  # Set connection pool to match concurrency
  database_url = ENV["DATABASE_URL"]
  if database_url
    ENV["DATABASE_URL"] = "#{database_url}?pool=#{AppConfig.environment.sidekiq.concurrency.get}"
    ActiveRecord::Base.establish_connection
  end

  # Make sure each Sidekiq process has its own sequence of UUIDs
  UUID.generator.next_sequence
end

Sidekiq.configure_client do |config|
  config.redis = AppConfig.get_redis_options
end
