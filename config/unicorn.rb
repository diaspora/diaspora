require_relative "load_config"

port = ENV["PORT"]
port = port && !port.empty? ? port.to_i : nil

listen port || AppConfig.server.listen.get unless RACKUP[:set_listener]
pid AppConfig.server.pid.get if AppConfig.server.pid?
worker_processes AppConfig.server.unicorn_worker.to_i
timeout AppConfig.server.unicorn_timeout.to_i
stderr_path AppConfig.server.stderr_log.get if AppConfig.server.stderr_log?
stdout_path AppConfig.server.stdout_log.get if AppConfig.server.stdout_log?

preload_app true
@sidekiq_pid = nil

before_fork do |_server, _worker|
  ActiveRecord::Base.connection.disconnect! # preloading app in master, so reconnect to DB

  # disconnect redis if in use
  unless AppConfig.environment.single_process_mode?
    Sidekiq.redis {|redis| redis.client.disconnect }
  end

  if AppConfig.server.embed_sidekiq_worker?
    @sidekiq_pid ||= spawn("bin/bundle exec sidekiq")
  end
end

after_fork do |_server, _worker|
  Logging.reopen # reopen logfiles to obtain a new file descriptor

  ActiveRecord::Base.establish_connection # preloading app in master, so reconnect to DB

  # We don't generate uuids in the frontend, but let's be on the safe side
  UUID.generator.next_sequence
end
