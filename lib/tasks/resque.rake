require 'resque/tasks'

task "resque:setup" do
  require File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment')
  Rails.logger.info("event=resque_setup rails_env=#{Rails.env}")

  Resque.after_fork = Proc.new { ActiveRecord::Base.establish_connection }
end

desc "Alias for resque:work (To run workers on Heroku)"
task "jobs:work" => "resque:work"

desc 'clear your failure queue in resque.  good for crons.'
task 'resque:clear_failed' => [:environment]  do
  puts "clearing resque failures"
  Resque::Failure.clear
  puts "complete!"
end
