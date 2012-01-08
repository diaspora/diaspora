module Resque
  def enqueue(klass, *args)
    klass.send(:perform, *args)
  end
end