module Resque
  def enqueue(klass, *args)
    if $process_queue
      klass.send(:perform, *args)
    else
      true
    end
  end
end

module HelperMethods
  def fantasy_resque
    former_value = $process_queue
    $process_queue = true
    result = yield
    $process_queue = former_value
    result
  end
end
