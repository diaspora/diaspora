# frozen_string_literal: true

require_relative "load_config"

port = ENV["PORT"]
port = port && !port.empty? ? port.to_i : nil

listen port || AppConfig.server.listen.get unless RACKUP[:set_listener]
pid AppConfig.server.pid.get
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

after_fork do |server, worker|
  Logging.reopen # reopen logfiles to obtain a new file descriptor

  ActiveRecord::Base.establish_connection # preloading app in master, so reconnect to DB

  # We don't generate uuids in the frontend, but let's be on the safe side
  UUID.generator.next_sequence

  # Check for an old master process from a graceful restart
  old_pid = "#{AppConfig.server.pid.get}.oldbin"

  if File.exist?(old_pid) && server.pid != old_pid
    begin
      # Remove a worker from the old master when we fork a new one (TTOU)
      # Except for the last worker forked by this server, which kills the old master (QUIT)
      signal = (worker.nr + 1) >= server.worker_processes ? :QUIT : :TTOU
      Process.kill(signal, File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end
