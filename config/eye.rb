require_relative "load_config"
rails_env = ENV["RAILS_ENV"] || ENV["RACK_ENV"] || "development"

Eye.config do
  logger Logger.new(STDOUT)
end

Eye.application("diaspora") do
  working_dir Rails.root.to_s
  env "DB" => ENV["DB"], "RAILS_ENV" => rails_env
  stdout "log/eye_processes_stdout.log" unless rails_env == "development"
  stderr "log/eye_processes_stderr.log"

  process :web do
    start_command "bin/bundle exec unicorn -c config/unicorn.rb"
    daemonize true
    pid_file "tmp/pids/web.pid"
    stop_signals [:TERM, 10.seconds]
    env "PORT" => ENV["PORT"]

    monitor_children do
      stop_command "kill -QUIT {PID}"
    end
  end

  group :sidekiq do
    with_condition(!AppConfig.environment.single_process_mode?) do
      AppConfig.server.sidekiq_workers.to_i.times do |i|
        i += 1

        process "sidekiq#{i}" do
          start_command "bin/bundle exec sidekiq"
          daemonize true
          pid_file "tmp/pids/sidekiq#{i}.pid"
          stop_signals [:USR1, 0, :TERM, 10.seconds, :KILL]
        end
      end
    end
  end

  with_condition(AppConfig.chat.enabled? && AppConfig.chat.server.enabled?) do
    process :xmpp do
      start_command "bin/bundle exec vines start"
      daemonize true
      pid_file "tmp/pids/xmpp.pid"
      stop_signals [:TERM, 10.seconds, :KILL]
    end
  end
end
