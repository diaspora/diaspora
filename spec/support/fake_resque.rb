module Resque
  def enqueue(klass, *args)
    if $process_queue
      begin
        klass.send(:perform, *args)
      rescue RuntimeError => e
        e.message == 'retry'
      end
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
