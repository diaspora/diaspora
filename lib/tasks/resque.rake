require 'resque/tasks'
task "resque:setup" => :environment do
  Dir[File.join(Rails.root, 'app', 'uploaders', '*.rb')].each { |file|
    classname = File.basename(file)[0..-4].camelize.constantize
    unless defined?(classname)
      require file 
    end
  }
  Dir[File.join(Rails.root, 'app', 'models', '*.rb')].each { |file| 
    classname = File.basename(file)[0..-4].camelize.constantize
    unless defined?(classname)
      require file 
    end
  }
  require File.join(Rails.root, 'app', 'controllers', 'application_controller.rb')
  require File.join(Rails.root, 'app', 'controllers', 'sockets_controller.rb')
  Rails.logger.info("event=resque_setup rails_env=#{Rails.env}")
end

