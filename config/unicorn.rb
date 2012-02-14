rails_env = ENV['RAILS_ENV'] || 'development'

# Enable and set these to run the worker as a different user/group
#user  = 'diaspora'
#group = 'diaspora'

worker_processes 1

## Load the app before spawning workers
preload_app true

# How long to wait before killing an unresponsive worker
timeout 30

#pid '/var/run/diaspora/diaspora.pid'
#listen '/var/run/diaspora/diaspora.sock', :backlog => 2048

# Ruby Enterprise Feature
if GC.respond_to?(:copy_on_write_friendly=)
  GC.copy_on_write_friendly = true
end


before_fork do |server, worker|
  # If using preload_app, enable this line
  ActiveRecord::Base.connection.disconnect!

  # disconnect redis if in use
  if !AppConfig.single_process_mode?
    Resque.redis.client.disconnect
  end

  old_pid = '/var/run/diaspora/diaspora.pid.oldbin'
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end


after_fork do |server, worker|
  # If using preload_app, enable this line
  ActiveRecord::Base.establish_connection

  # copy pasta from resque.rb because i'm a bad person
  if !AppConfig.single_process_mode?
    if redis_to_go = ENV["REDISTOGO_URL"]
      uri = URI.parse(redis_to_go)
      Resque.redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
    elsif AppConfig[:redis_url]
      Resque.redis = Redis.new(:host => AppConfig[:redis_url], :port => 6379)
    end
  end

  # Enable this line to have the workers run as different user/group
  #worker.user(user, group)
end
