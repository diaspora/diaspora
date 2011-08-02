# Copyright 2008 David Vollbracht & Philippe Hanrigou

module SystemTimer

  # Timer saving associated thread. This is needed because we trigger timers 
  # from a Ruby signal handler and Ruby signals are always delivered to 
  # main thread.
  class ThreadTimer
    attr_reader :trigger_time, :thread, :exception_class
    
    def initialize(trigger_time, thread, exception_class = nil)
      @trigger_time = trigger_time
      @thread = thread
	  @exception_class = exception_class || Timeout::Error
    end
    
    def to_s
      "<ThreadTimer :time => #{trigger_time}, :thread => #{thread}, :exception_class => #{exception_class}>"
    end
    
  end
end
