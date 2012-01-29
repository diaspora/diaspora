# # your config.ru
# require 'unicorn_killer'
# use UnicornKiller::MaxRequests, 1000
# use UnicornKiller::Oom, 400 * 1024

module UnicornKiller
  module Kill
    def quit
      sec = (Time.now - @process_start).to_i
      warn "#{self.class} send SIGQUIT (pid: #{Process.pid})\talive: #{sec} sec"
      Process.kill :QUIT, Process.pid 
    end
  end 

  class Oom
    include Kill

    def initialize(app, memory_size= 512 * 1024, check_cycle = 10)
      @app = app
      @memory_size = memory_size
      @check_cycle = check_cycle
      @check_count = 0
    end 

    def rss
      `ps -o rss= -p #{Process.pid}`.to_i
    end

    def call(env)
      @process_start ||= Time.now
      if (@check_count += 1) % @check_cycle == 0
        @check_count = 0
        quit if rss > @memory_size
      end
      @app.call env
    end
  end

  class MaxRequests
    include Kill

    def initialize(app, max_requests = 1000)
      @app = app 
      @max_requests = max_requests
    end

    def call(env)
      @process_start ||= Time.now
      quit if (@max_requests -= 1) == 0
      @app.call env
    end
  end
end
