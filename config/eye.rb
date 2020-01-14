# frozen_string_literal: true

require_relative "load_config"
rails_env = ENV["RAILS_ENV"] || ENV["RACK_ENV"] || "development"

Eye.config do
  logger Logger.new(STDOUT)
end

Eye.application("diaspora") do
  working_dir Rails.root.to_s
  env "RAILS_ENV" => rails_env
  stdout "log/eye_processes_stdout.log" unless rails_env == "development"
  stderr "log/eye_processes_stderr.log"

  process :web do
    unicorn_command = "bin/bundle exec unicorn -c config/unicorn.rb"

    if rails_env == "production"
      start_command "#{unicorn_command} -D"
      daemonize false
      restart_command "kill -USR2 {PID}"
      restart_grace 10.seconds
    else
      start_command unicorn_command
      daemonize true
    end

    pid_file AppConfig.server.pid.get
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
end
