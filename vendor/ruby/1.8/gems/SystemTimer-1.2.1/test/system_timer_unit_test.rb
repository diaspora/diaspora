require File.dirname(__FILE__) + '/test_helper'

unit_tests do
  
  test "timeout_after registers a new timer in the timer pool" do
    pool = stub_everything
    Thread.stubs(:current).returns(:the_current_thread)
    SystemTimer.stubs(:timer_pool).returns(pool)
    SystemTimer.stubs(:install_next_timer)
    SystemTimer.stubs(:restore_original_configuration)

    pool.expects(:add_timer).with(5, nil).returns(stub_everything)
    SystemTimer.timeout_after(5) {}    
  end

  test "timeout_after registers a new timer with a custom timeout exception in the timer pool" do
    MyCustomException = Class.new(Exception)
    pool = stub_everything
    Thread.stubs(:current).returns(:the_current_thread)
    SystemTimer.stubs(:timer_pool).returns(pool)
    SystemTimer.stubs(:install_next_timer)
    SystemTimer.stubs(:restore_original_configuration)

    pool.expects(:add_timer).with(5, MyCustomException).returns(stub_everything)
    SystemTimer.timeout_after(5, MyCustomException) {}    
  end

  test "timeout_after installs a system timer saving the previous " +
       "configuration when there is only one timer" do
         
    now = Time.now
    Time.stubs(:now).returns(now)
    SystemTimer.stubs(:restore_original_configuration)
    SystemTimer.expects(:install_first_timer_and_save_original_configuration) \
               .with {|value| value.between?(23.99, 24.01) }
    SystemTimer.timeout_after(24) {}    
  end

  test "timeout_after installs a system timer without saving the previous " +
       "configuration when there is more than one timer" do
         
    now = Time.now
    Time.stubs(:now).returns(now)
    SystemTimer.timer_pool.register_timer now.to_f + 100, :a_thread
    SystemTimer.stubs(:restore_original_configuration)
    SystemTimer.stubs(:install_next_timer)

    SystemTimer.expects(:install_next_timer) \
               .with {|value| value.between?(23.99, 24.01) }
    SystemTimer.timeout_after(24) {}    
  end

  test "timeout_after installs a system timer with the interval before " +
       "the next timer to expire" do
         
    now = Time.now
    Time.stubs(:now).returns(now)
    SystemTimer.timer_pool.register_timer now.to_f + 24, :a_thread
    SystemTimer.stubs(:restore_original_configuration)
    SystemTimer.stubs(:install_next_timer)

    SystemTimer.expects(:install_next_timer) \
               .with {|value| value.between?(23.99, 24.01) }
    SystemTimer.timeout_after(100) {}    
  end
  
  test "timeout_after cancels the timer when the block completes without " +
       "timeout" do
         
    now = Time.now
    the_timer = stub_everything
    Time.stubs(:now).returns(now)
    SystemTimer.stubs(:restore_original_configuration)
    SystemTimer.stubs(:install_first_timer_and_save_original_configuration)    
    SystemTimer.timer_pool.stubs(:add_timer).returns(the_timer)
    SystemTimer.timer_pool.stubs(:first_timer?).returns(true)
    
    SystemTimer.timer_pool.expects(:cancel).with(the_timer)
    SystemTimer.timeout_after(24) {}    
  end

 test "debug does not output to stdout when debug is disabled"  do
   SystemTimer.stubs(:debug_enabled?).returns(false)
   original_stdout = $stdout
   begin
     stdout = StringIO.new
     $stdout = stdout
   
     SystemTimer.send :debug, "a log message"
     assert stdout.string.empty?
   ensure
     $stdout = original_stdout
   end   
 end

 test "debug logs messaget to stdout when debug is enabled"  do
   SystemTimer.stubs(:debug_enabled?).returns(true)
   original_stdout = $stdout
   begin
     stdout = StringIO.new
     $stdout = stdout
   
     SystemTimer.send :debug, "a log message"
     assert_match /a log message/, stdout.string
   ensure
     $stdout = original_stdout
   end   
 end

end
