module Resque
  # The Failure module provides an interface for working with different
  # failure backends.
  #
  # You can use it to query the failure backend without knowing which specific
  # backend is being used. For instance, the Resque web app uses it to display
  # stats and other information.
  module Failure
    # Creates a new failure, which is delegated to the appropriate backend.
    #
    # Expects a hash with the following keys:
    #   :exception - The Exception object
    #   :worker    - The Worker object who is reporting the failure
    #   :queue     - The string name of the queue from which the job was pulled
    #   :payload   - The job's payload
    def self.create(options = {})
      backend.new(*options.values_at(:exception, :worker, :queue, :payload)).save
    end

    #
    # Sets the current backend. Expects a class descendent of
    # `Resque::Failure::Base`.
    #
    # Example use:
    #   require 'resque/failure/hoptoad'
    #   Resque::Failure.backend = Resque::Failure::Hoptoad
    def self.backend=(backend)
      @backend = backend
    end

    # Returns the current backend class. If none has been set, falls
    # back to `Resque::Failure::Redis`
    def self.backend
      return @backend if @backend
      require 'resque/failure/redis'
      @backend = Failure::Redis
    end

    # Returns the int count of how many failures we have seen.
    def self.count
      backend.count
    end

    # Returns an array of all the failures, paginated.
    #
    # `start` is the int of the first item in the page, `count` is the
    # number of items to return.
    def self.all(start = 0, count = 1)
      backend.all(start, count)
    end

    # The string url of the backend's web interface, if any.
    def self.url
      backend.url
    end
    
    # Clear all failure jobs
    def self.clear
      backend.clear
    end
    
    def self.requeue(index)
      backend.requeue(index)
    end
  end
end
