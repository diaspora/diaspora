require 'resque'

Resque::Plugins::Timeout.timeout = 120

if !AppConfig[:single_process_mode] && AppConfig[:redis_url]
  Resque.redis = Redis.new(:host => AppConfig[:redis_url], :port => 6379)
end

if AppConfig[:single_process_mode]
  if Rails.env == 'production'
    puts "WARNING: You are running Diaspora in production without Resque workers turned on.  Please don't do this."
  end
  module Resque
    def enqueue(klass, *args)
      begin 
        klass.send(:perform, *args)
      rescue Exception => e
        Rails.logger.warn(e.message)
        nil
      end
    end
  end
end
