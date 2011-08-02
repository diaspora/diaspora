require File.dirname(__FILE__) + '/../test_helper'

unit_tests do
  
  test "registered_timers is empty when there is no registered timers" do
    assert_equal [], SystemTimer::ConcurrentTimerPool.new.registered_timers
  end

  test "a new timer is added to the registered timer list when you register a timer" do
    pool = SystemTimer::ConcurrentTimerPool.new
    pool.register_timer :a_trigger_time, :a_thread 
    assert_equal [[:a_trigger_time, :a_thread]], 
                 pool.registered_timers.collect {|t| [t.trigger_time, t.thread] }
  end

  test "register_timer returns the timer that was just added to the pool" do
    pool = SystemTimer::ConcurrentTimerPool.new
    timer = pool.register_timer :a_trigger_time, :a_thread 
    assert_equal [:a_trigger_time, :a_thread], [timer.trigger_time, timer.thread]
  end

  test "add_timer is a shortcut method to register a timer given its interval" do
    pool = SystemTimer::ConcurrentTimerPool.new
    Thread.stubs(:current).returns(:the_current_thread)
    now = Time.now
    Time.stubs(:now).returns(now)
    
    pool.expects(:register_timer).with(now.to_f + 15, :the_current_thread, nil)
    pool.add_timer 15
  end

  test "cancel removes a timer from the registered timer list" do
    pool = SystemTimer::ConcurrentTimerPool.new
    registered_timer = pool.register_timer :a_trigger_time, :a_thread
    pool.cancel registered_timer
    assert_equal [], pool.registered_timers
  end

  test "cancel does not complain when timer is cancelled " +
       "(useful for ensure blocks)" do
         
    pool = SystemTimer::ConcurrentTimerPool.new
    a_timer = pool.add_timer 123
    another_timer = pool.add_timer 456
    pool.cancel(another_timer)
    pool.cancel(another_timer)
    assert_equal [a_timer], pool.registered_timers
  end
  
  test "first_timer? returns false when there is no timer" do
    assert_equal false, SystemTimer::ConcurrentTimerPool.new.first_timer?
  end

  test "first_timer? returns true when there is a single timer" do
    pool = SystemTimer::ConcurrentTimerPool.new
    pool.add_timer 7
    assert_equal true, pool.first_timer?
  end

  test "first_timer? returns false when there is more than one timer" do
    pool = SystemTimer::ConcurrentTimerPool.new
    pool.add_timer 7
    pool.add_timer 3
    assert_equal false, pool.first_timer?
  end

  test "first_timer? returns false when there is a single timer left" do
    pool = SystemTimer::ConcurrentTimerPool.new
    first_timer = pool.add_timer 7
    pool.add_timer 3
    pool.cancel first_timer
    assert_equal true, pool.first_timer?
  end
  
  test "next expired timer return nil when there is no registered timer" do
    assert_nil SystemTimer::ConcurrentTimerPool.new.next_expired_timer(24)
  end

  test "next_timer returns nil when there is no registered timer" do
    assert_nil SystemTimer::ConcurrentTimerPool.new.next_timer
  end

  test "next_timer returns the registered timer when " +
       "there is only one registered timer" do
         
    pool = SystemTimer::ConcurrentTimerPool.new
    the_timer = pool.register_timer 24, stub_everything
    assert_equal the_timer, pool.next_timer
  end

  test "next_timer returns the trigger time of the first timer to" +
       "expire when there is more than one registered timer" do
         
    pool = SystemTimer::ConcurrentTimerPool.new
    late_timer = pool.register_timer 64, stub_everything
    early_timer = pool.register_timer 24, stub_everything
    assert_equal early_timer, pool.next_timer
  end

  test "next_trigger_time returns nil when next_timer is nil" do
    pool = SystemTimer::ConcurrentTimerPool.new
    pool.expects(:next_timer).returns(nil)
    assert_nil pool.next_trigger_time
  end

  test "next_trigger_time returns trigger time of next timer when " +
       "next timer is not nil" do
         
    pool = SystemTimer::ConcurrentTimerPool.new
    the_timer = SystemTimer::ThreadTimer.new 24, stub_everything
    pool.expects(:next_timer).returns(the_timer)
    assert_equal 24, pool.next_trigger_time
  end

  test "next_trigger_interval_in_seconds returns nil when next_timer is nil" do
    pool = SystemTimer::ConcurrentTimerPool.new
    pool.expects(:next_timer).returns(nil)
    assert_nil pool.next_trigger_interval_in_seconds
  end

  test "next_trigger_interval_in_seconds returns the interval between now and " +
       "next_timer timer time when next timer is in the future" do
    pool = SystemTimer::ConcurrentTimerPool.new
    now = Time.now
    Time.stubs(:now).returns(now)
    next_timer = SystemTimer::ThreadTimer.new((now.to_f + 7), stub_everything)
    pool.expects(:next_timer).returns(next_timer)
    assert_equal 7, pool.next_trigger_interval_in_seconds
  end

  test "next_trigger_interval_in_seconds returns 0 when next timer is now" do
    pool = SystemTimer::ConcurrentTimerPool.new
    now = Time.now
    Time.stubs(:now).returns(now)
    next_timer = SystemTimer::ThreadTimer.new now.to_f, stub_everything
    pool.expects(:next_timer).returns(next_timer)
    assert_equal 0, pool.next_trigger_interval_in_seconds
  end

  test "next_trigger_interval_in_seconds returns 0 when next timer is in the past" do
    pool = SystemTimer::ConcurrentTimerPool.new
    now = Time.now
    Time.stubs(:now).returns(now)
    next_timer = SystemTimer::ThreadTimer.new((now.to_f - 3), stub_everything)
    pool.expects(:next_timer).returns(next_timer)
    assert_equal 0, pool.next_trigger_interval_in_seconds
  end

  test "next_expired_timer returns the timer that was trigerred" +
       "when a timer has expired" do
         
    pool = SystemTimer::ConcurrentTimerPool.new
    the_timer = pool.register_timer 24, :a_thread
    assert_equal the_timer, pool.next_expired_timer(24)
  end  

  test "next_expired_timer returns nil when no timer has expired yet" do
    pool = SystemTimer::ConcurrentTimerPool.new
    pool.register_timer 24, :a_thread
    assert_nil pool.next_expired_timer(23)
  end  

  test "next_expired_timer returns the timer that first expired " +
       "when there is more than one expired timer" do
         
    pool = SystemTimer::ConcurrentTimerPool.new
    last_to_expire = pool.register_timer 64, :a_thread
    first_to_expire = pool.register_timer 24, :a_thread
    assert_equal first_to_expire, pool.next_expired_timer(100)
  end  

  test "trigger_next_expired_timer_at does not raise when there is no registered timer" do
    SystemTimer::ConcurrentTimerPool.new.trigger_next_expired_timer_at 1234
  end

  test "trigger_next_expired_timer_at raises a TimeoutError in the context of " +
       "its thread when there is a registered timer that has expired" do
       
    pool = SystemTimer::ConcurrentTimerPool.new
    the_thread = mock('thread')
    
    Timeout::Error.expects(:new).with("time's up!").returns(:the_exception)
    the_thread.expects(:raise).with(:the_exception)
    pool.register_timer 24, the_thread 
    pool.trigger_next_expired_timer_at 24
  end

  test "trigger_next_expired_timer_at does not raise when registered timer has not expired" do
    pool = SystemTimer::ConcurrentTimerPool.new
    pool.register_timer 24, stub_everything
    pool.trigger_next_expired_timer_at(10)
  end

  test "trigger_next_expired_timer_at triggers the first registered timer that expired" do
    pool = SystemTimer::ConcurrentTimerPool.new
    first_to_expire = pool.register_timer 24, stub_everything
    second_to_expire = pool.register_timer 64, stub_everything
    pool.trigger_next_expired_timer_at(100)
    assert_equal [second_to_expire], pool.registered_timers
  end

  test "trigger_next_expired_timer_at triggers the first registered timer that " +
       "expired whatever the timer insertion order is" do
         
    pool = SystemTimer::ConcurrentTimerPool.new
    second_to_expire = pool.register_timer 64, stub_everything
    first_to_expire = pool.register_timer 24, stub_everything
    pool.trigger_next_expired_timer_at(100)
    assert_equal [second_to_expire], pool.registered_timers
  end

  test "trigger_next_expired_timer_at remove the expired timer from the pool" do       
    pool = SystemTimer::ConcurrentTimerPool.new
    pool.register_timer 24, stub_everything 
    pool.trigger_next_expired_timer_at 24
  end

  test "trigger_next_expired_timer_at logs timeout a registered timer has expired" +
       "and SystemTimer debug mode is enabled " do

    original_stdout = $stdout
    begin
      stdout = StringIO.new
      $stdout = stdout

      pool = SystemTimer::ConcurrentTimerPool.new
      the_timer = pool.register_timer 24, stub_everything
      SystemTimer.stubs(:debug_enabled?).returns(true)
  
      pool.expects(:log_timeout_received).with(the_timer)
      pool.trigger_next_expired_timer_at 24
    ensure
      $stdout = original_stdout
    end
  end

  test "trigger_next_expired_timer_at does not logs timeoout when SystemTimer " +
       "debug mode is disabled " do
         
    pool = SystemTimer::ConcurrentTimerPool.new
    the_timer = pool.register_timer 24, stub_everything
    SystemTimer.stubs(:debug_enabled?).returns(false)

    pool.expects(:log_timeout_received).never
    pool.trigger_next_expired_timer_at 24
  end

  test "trigger_next_expired_timer_at does not logs timeout no registered timer " +
       "has expired and SystemTimer debug mode is enabled " do

    original_stdout = $stdout
    begin
      stdout = StringIO.new
      $stdout = stdout
         
      pool = SystemTimer::ConcurrentTimerPool.new
      the_timer = pool.register_timer 24, stub_everything
      SystemTimer.stubs(:debug_enabled?).returns(true)

      pool.expects(:log_timeout_received).never
      pool.trigger_next_expired_timer_at 23
    ensure
      $stdout = original_stdout
    end
  end
  
  test "trigger_next_expired_timer is a shorcut method calling " +
       "trigger_next_expired_timer_at with current epoch time" do
    
    now = Time.now
    pool = SystemTimer::ConcurrentTimerPool.new
    Time.stubs(:now).returns(now)
    
    pool.expects(:trigger_next_expired_timer_at).with(now.to_f)
    pool.trigger_next_expired_timer
  end
  
  test "log_timeout_received does not raise" do
    original_stdout = $stdout
    begin
      stdout = StringIO.new
      $stdout = stdout
    
      SystemTimer::ConcurrentTimerPool.new.log_timeout_received(SystemTimer::ThreadTimer.new(:a_time, :a_thread))
      assert_match %r{==== Triger Timer ====}, stdout.string
    ensure
      $stdout = original_stdout
    end
  end
    
end
