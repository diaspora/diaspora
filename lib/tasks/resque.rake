require 'resque/tasks'
task "resque:setup" => :environment do
  Dir[File.join(Rails.root, 'app', 'uploaders', '*.rb')].each { |file| require file }
  Dir[File.join(Rails.root, 'app', 'models', '*.rb')].each { |file| require file }
  Rails.logger.info("event=resque_setup rails_env=#{Rails.env}")
end

