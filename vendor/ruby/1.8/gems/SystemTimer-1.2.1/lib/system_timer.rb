# Copyright 2008 David Vollbracht & Philippe Hanrigou

if defined?(RUBY_ENGINE) and RUBY_ENGINE == "rbx"
  require File.dirname(__FILE__) + '/system_timer_stub'
else

require 'rubygems'
require 'timeout'
require 'forwardable'
require 'monitor'
require File.dirname(__FILE__) + '/system_timer/thread_timer'
require File.dirname(__FILE__) + '/system_timer/concurrent_timer_pool'

# Timer based on underlying +ITIMER_REAL+ system timer. It is a
# solution to Ruby processes which hang beyond the time limit when accessing
# external resources. This is useful when timeout.rb, which relies on green
# threads, does not work consistently.
#
# For more information and background check out:
#
# * http://ph7spot.com/articles/system_timer
# * http://davidvollbracht.com/2008/6/2/30-days-of-teach-day-1-systemtimer
#
# == Usage
#
#   require 'systemtimer'
#
#   SystemTimer.timeout_after(5) do
#
#     # Something that should be interrupted if it takes too much time...
#     # ... even if blocked on a system call!
#
#   end
#
module SystemTimer

  Thread.exclusive do    # Avoid race conditions for monitor and pool creation
    @timer_pool = ConcurrentTimerPool.new
    @monitor = Monitor.new
  end
  
  class << self
    attr_reader :timer_pool   
   
    # Executes the method's block. If the block execution terminates before 
    # +seconds+ seconds has passed, it returns true. If not, it terminates 
    # the execution and raises a +Timeout::Error+.
    def timeout_after(seconds, exception_class = nil)
      new_timer = nil                                      # just for scope
      @monitor.synchronize do
        new_timer = timer_pool.add_timer seconds, exception_class
        timer_interval = timer_pool.next_trigger_interval_in_seconds
        debug "==== Install Timer ==== at #{Time.now.to_f}, next interval: #{timer_interval}"
        if timer_pool.first_timer?
          install_first_timer_and_save_original_configuration timer_interval
        else
          install_next_timer timer_interval
        end
     end
      return yield
    ensure
      @monitor.synchronize do
        debug "==== Cleanup Timer ==== at #{Time.now.to_f}, #{new_timer} "
        timer_pool.cancel new_timer
        timer_pool.log_registered_timers if debug_enabled?
        next_interval = timer_pool.next_trigger_interval_in_seconds
        debug "Cleanup Timer : next interval #{next_interval.inspect} "
        if next_interval
          install_next_timer next_interval
        else
          restore_original_configuration          
        end
      end
    end
   
    # Backward compatibility with timeout.rb
    alias timeout timeout_after 
   
   protected
   
   def install_ruby_sigalrm_handler            #:nodoc:
     @original_ruby_sigalrm_handler = trap('SIGALRM') do
       @monitor.synchronize do
          # Triggers timers one at a time to ensure more deterministic results
          timer_pool.trigger_next_expired_timer
       end
     end
   end
  
   def restore_original_ruby_sigalrm_handler   #:nodoc:
     trap('SIGALRM', original_ruby_sigalrm_handler || 'DEFAULT')
   ensure
     reset_original_ruby_sigalrm_handler
   end
   
   def original_ruby_sigalrm_handler           #:nodoc:
     @original_ruby_sigalrm_handler
   end
 
   def reset_original_ruby_sigalrm_handler     #:nodoc:
     @original_ruby_sigalrm_handler = nil
   end

   def debug(message)    #:nodoc
     puts message if debug_enabled?
   end
     
 end

end

require 'system_timer_native'


end # stub guard
