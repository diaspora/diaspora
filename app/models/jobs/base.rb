module Job
  class Base
    extend ResqueJobLogging

    def self.perform(*args)  
      ActiveRecord::Base.verify_active_connections!  
      self.perform_delegate(*args)  
    end

    def self.perform_delegate(*args) # override this  
    end
  end
end
