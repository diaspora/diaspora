module Resque
  # Raised whenever we need a queue but none is provided.
  class NoQueueError < RuntimeError; end

  # Raised when trying to create a job without a class
  class NoClassError < RuntimeError; end
  
  # Raised when a worker was killed while processing a job.
  class DirtyExit < RuntimeError; end
end
