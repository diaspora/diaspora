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

  config.options = config.options.merge({
    concurrency: AppConfig.environment.sidekiq.concurrency.to_i,
    queues: %w{
      socket_webfinger
      photos
      http_service
      dispatch
      mail
      delete_account
      receive_local
      receive
      receive_salmon
      http
      default
    }
  })

  config.server_middleware do |chain|
    chain.add SidekiqMiddlewares::CleanAndShortBacktraces
  end

  Sidekiq::Logging.initialize_logger AppConfig.sidekiq_log unless AppConfig.heroku?

  # Set connection pool on Heroku
  database_url = ENV['DATABASE_URL']
  if(database_url)
    ENV['DATABASE_URL'] = "#{database_url}?pool=#{AppConfig.environment.sidekiq.concurrency.get}"
    ActiveRecord::Base.establish_connection
  end
end

Sidekiq.configure_client do |config|
  config.redis = AppConfig.get_redis_options
end
