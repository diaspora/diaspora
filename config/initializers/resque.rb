require 'resque'

Resque::Plugins::Timeout.timeout = 120

if !AppConfig.single_process_mode?
  if redis_to_go = ENV["REDISTOGO_URL"]
    uri = URI.parse(redis_to_go)
    Resque.redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
  elsif AppConfig[:redis_url]
    Resque.redis = Redis.new(:host => AppConfig[:redis_url], :port => 6379)
  end
end

if AppConfig.single_process_mode?
  if Rails.env == 'production'
    puts "WARNING: You are running Diaspora in production without Resque workers turned on.  Please don't do this."
  end
  module Resque
    def enqueue(klass, *args)
      begin 
        klass.send(:perform, *args)
      rescue Exception => e
        Rails.logger.warn(e.message)
        raise e
        nil
      end
    end
  end
end

if AppConfig.mount_resque_web
  require 'resque/server'

  class AdminRack
    def initialize(app)
      @app = app
    end

    def call(env)
      user = env['warden'].authenticate(:scope => :user)
      if user && user.admin?
        @app.call(env)
      else
        [307, {"Location" => '/'}, self]
      end
    end

    def each(&block)
    end
  end

  Resque::Server.use AdminRack
end
