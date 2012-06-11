require 'resque'

Resque::Plugins::Timeout.timeout = 300

if !AppConfig.single_process_mode?
  if redis_to_go = ENV["REDISTOGO_URL"]
    uri = URI.parse(redis_to_go)
    Resque.redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
  elsif ENV['RAILS_ENV']== 'integration2'
    Resque.redis = Redis.new(:host => 'localhost', :port => 6380)
  elsif AppConfig[:redis_url]
    Resque.redis = Redis.new(:host => AppConfig[:redis_url], :port => 6379)
  end
end

# Single process-mode hooks using Resque.inline
if AppConfig.single_process_mode?
  if Rails.env == 'production'
    puts "WARNING: You are running Diaspora in production without Resque workers turned on.  Please don't do this."
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
