require 'resque/tasks'
task "resque:setup" => :environment do
  Dir[File.join(Rails.root, 'app', 'uploaders', '*.rb')].each { |file|
    class_name = File.basename(file)[0..-4].camelize
    begin
      klass = Module.const_get(class_name)
      klass.is_a?(Class)
    rescue NameError
      require file
    end
  }
  Dir[File.join(Rails.root, 'app', 'models', '*.rb')].each { |file|
    class_name = File.basename(file)[0..-4].camelize
    begin
      klass = Module.const_get(class_name)
      klass.is_a?(Class)
    rescue NameError
      require file
    end
  }
  require File.join(Rails.root, 'app', 'controllers', 'application_controller.rb')
  require File.join(Rails.root, 'app', 'controllers', 'sockets_controller.rb')
  Rails.logger.info("event=resque_setup rails_env=#{Rails.env}")
end

