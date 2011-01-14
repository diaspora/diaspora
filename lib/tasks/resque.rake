require 'resque/tasks'
task "resque:setup" do
  require 'config/environment'
  Rails.logger.info("event=resque_setup rails_env=#{Rails.env}")
end
