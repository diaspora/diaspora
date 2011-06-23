module Job
  class Base
    extend ResqueJobLogging

    # Perform this job.  This wrapper method
    def self.perform(*args)
      ActiveRecord::Base.verify_active_connections!
      self.perform_delegate(*args)
    end

    # Override this in your Job class.
    # @abstract
    def self.perform_delegate(*args)
    end
  end
end
