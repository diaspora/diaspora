require 'resque'

Resque::Plugins::Timeout.timeout = 300

if !AppConfig.environment.single_process_mode?
  Resque.redis = AppConfig.get_redis_instance
end

# Single process-mode hooks using Resque.inline
if AppConfig.environment.single_process_mode?
  if Rails.env == 'production'
    puts "WARNING: You are running Diaspora in production without Resque"
    puts "  workers turned on.  Please set single_process_mode to false in"
    puts "  config/diaspora.yml."
  end
  Resque.inline = true
end

if AppConfig.admins.monitoring.airbrake_api_key.present?
  require 'resque/failure/multiple'
  require 'resque/failure/airbrake'
  require 'resque/failure/redis'
  Resque::Failure::Airbrake.configure do |config|
    config.api_key = AppConfig.admins.monitoring.airbrake_api_key
    config.secure = true
  end
  Resque::Failure::Multiple.classes = [Resque::Failure::Redis, Resque::Failure::Airbrake]
  Resque::Failure.backend = Resque::Failure::Multiple
end


if AppConfig.admins.inline_resque_web?
  require 'resque/server'
  require Rails.root.join('lib', 'admin_rack')
  Resque::Server.use AdminRack
end
