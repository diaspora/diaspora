require 'resque'

Resque::Plugins::Timeout.timeout = 300

if !AppConfig.single_process_mode?
  if redis_to_go = ENV["REDISTOGO_URL"]
    uri = URI.parse(redis_to_go)
    redis_options = { :host => uri.host, :port => uri.port,
                      :passsword => uri.password }
  elsif ENV['RAILS_ENV']== 'integration2'
    redis_options = { :host => 'localhost', :port => 6380 }
  elsif AppConfig[:redis_url].present?
    redis_options = { :url => AppConfig[:redis_url], :port => 6379 }
  end
  
  if redis_options
    Resque.redis = Redis.new(redis_options.merge(:thread_safe => true))
  end
end

# Single process-mode hooks using Resque.inline
if AppConfig.single_process_mode?
  if Rails.env == 'production'
    puts "WARNING: You are running Diaspora in production without Resque"
    puts "  workers turned on.  Please set single_process_mode to false in"
    puts "  config/application.yml."
  end
  Resque.inline = true
end

if AppConfig[:airbrake_api_key].present?
  require 'resque/failure/multiple'
  require 'resque/failure/airbrake'
  require 'resque/failure/redis'
  Resque::Failure::Airbrake.configure do |config|
    config.api_key = AppConfig[:airbrake_api_key]
    config.secure = true
  end
  Resque::Failure::Multiple.classes = [Resque::Failure::Redis, Resque::Failure::Airbrake]
  Resque::Failure.backend = Resque::Failure::Multiple
end


if AppConfig[:mount_resque_web]
  require 'resque/server'
  require Rails.root.join('lib', 'admin_rack')
  Resque::Server.use AdminRack
end
