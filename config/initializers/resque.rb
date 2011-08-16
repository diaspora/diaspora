require 'resque'

begin
  if AppConfig[:single_process_mode]
    if Rails.env == 'production'
      puts "WARNING: You are running Diaspora in production without Resque workers turned on.  Please don't do this."
    end
    module Resque
      def enqueue(klass, *args)
        klass.send(:perform, *args)
      end
    end
  end
rescue
  nil
end
