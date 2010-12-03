require 'resque/tasks'
task "resque:setup" => :environment do
  Dir[File.join(Rails.root, 'app', 'uploaders', '*.rb')].each { |file| require file }
  Dir[File.join(Rails.root, 'app', 'models', '*.rb')].each { |file| require file }
  require File.join(Rails.root, 'app', 'controllers', 'application_controller.rb')
  require File.join(Rails.root, 'app', 'controllers', 'sockets_controller.rb')
  Rails.logger.info("event=resque_setup rails_env=#{Rails.env}")
end

