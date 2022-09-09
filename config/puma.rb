# frozen_string_literal: true

require_relative "load_config"

pidfile AppConfig.server.pid.get
bind AppConfig.server.listen.get

worker_timeout AppConfig.server.web_timeout.to_i

if AppConfig.server.stdout_log? || AppConfig.server.stderr_log?
  stdout_redirect AppConfig.server.stdout_log? ? AppConfig.server.stdout_log.get : "/dev/null",
                  AppConfig.server.stderr_log? ? AppConfig.server.stderr_log.get : "/dev/null"
end

# In general, running Puma in cluster-mode is one of those very rare setups
# that's only relevant in *huge* scale. However, starting 1 worker runs Puma in
# cluster mode, with a single worker. This means you get to pay all the memory
# overhead of spawning in "cluster mode", but you don't get any performance
# benefits. This makes no sense. Setting "workers = 0" explicitly turns off
# cluster mode.
#
# For more details and further references, see
# https://github.com/puma/puma/commit/81d26e91b777ab120e8f52d45385f0e018438ba4
workers 0

preload_app!

before_fork do
  # we're preloading app in production, so force-reconenct the DB
  ActiveRecord::Base.connection_pool.disconnect!

  # drop the Redis connection
  Sidekiq.redis {|redis| redis.client.disconnect }
end

on_worker_boot do
  # reopen logfiles to obtain a new file descriptor
  Logging.reopen

  ActiveSupport.on_load(:active_record) do
    # we're preloading app in production, so reconnect to DB
    ActiveRecord::Base.establish_connection
  end

  # We don't generate uuids in the frontend, but let's be on the safe side
  UUID.generator.next_sequence
end
