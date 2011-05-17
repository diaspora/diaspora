require File.join(Rails.root, 'app', 'models', 'jobs', 'base')
Dir[File.join(Rails.root, 'app', 'models', 'jobs', '*.rb')].each { |file| require file }

require 'resque'

begin
  if Diaspora::Application.config.work_in_process
    module Resque
      def enqueue(klass, *args)
        klass.send(:perform, *args)
      end
    end
  end
end
