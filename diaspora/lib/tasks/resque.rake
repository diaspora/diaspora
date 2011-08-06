require 'resque/tasks'
task "resque:setup" do
  require File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment')
  Rails.logger.info("event=resque_setup rails_env=#{Rails.env}")
end
