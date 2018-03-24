# frozen_string_literal: true

require 'sidekiq_middlewares'
require 'sidekiq/middleware/i18n'

# Single process-mode
if AppConfig.environment.single_process_mode? && Rails.env != "test"
  if Rails.env == 'production'
    puts "WARNING: You are running Diaspora in production without Sidekiq"
    puts "         workers turned on.  Please set single_process_mode to false in"
    puts "         config/diaspora.yml."
  end
  require 'sidekiq/testing/inline'
end

Sidekiq.configure_server do |config|
  config.redis = AppConfig.get_redis_options

  config.server_middleware do |chain|
    chain.add SidekiqMiddlewares::CleanAndShortBacktraces
  end

  # Set connection pool on Heroku
  database_url = ENV['DATABASE_URL']
  if(database_url)
    ENV['DATABASE_URL'] = "#{database_url}?pool=#{AppConfig.environment.sidekiq.concurrency.get}"
    ActiveRecord::Base.establish_connection
  end

  # Make sure each Sidekiq process has its own sequence of UUIDs
  UUID.generator.next_sequence

  # wrap the logger to add the sidekiq job context to the log
  class SidekiqLogger < SimpleDelegator
    SPACE = " "

    # only info is used with context
    def info(data=nil)
      return false if Logger::Severity::INFO < level
      data = yield if data.nil? && block_given?
      __getobj__.info("#{context}#{data}")
    end

    # from sidekiq/logging.rb
    def context
      c = Thread.current[:sidekiq_context]
      "#{c.join(SPACE)}: " if c && c.any?
    end
  end

  Sidekiq::Logging.logger = SidekiqLogger.new(Logging.logger[Sidekiq])
end

Sidekiq.configure_client do |config|
  config.redis = AppConfig.get_redis_options
end

schedule_file = "config/schedule.yml"

if File.exist?(schedule_file) && Sidekiq.server?
  Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)
end
