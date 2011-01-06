module Resque
  def enqueue(klass, *args)
    if $process_queue
      klass.send(:perform, *args)
    else
      true
    end
  end
end
