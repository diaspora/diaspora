require File.dirname(__FILE__) + '/../test_helper'

unit_tests do
  
  test "trigger_time returns the time given in the constructor" do
    timer = SystemTimer::ThreadTimer.new(:a_tigger_time, nil)
    assert_equal :a_tigger_time, timer.trigger_time
  end

  test "thread returns the thread given in the constructor" do
    timer = SystemTimer::ThreadTimer.new(nil, :a_thread)
    assert_equal :a_thread, timer.thread
  end

  test "to_s retruns a human friendly description of the timer" do
    assert_match /<ThreadTimer :time => 24, :thread => #<Thread(.*)>, :exception_class => Timeout::Error>/, 
                 SystemTimer::ThreadTimer.new(24, Thread.current).to_s                 
  end
    
end
