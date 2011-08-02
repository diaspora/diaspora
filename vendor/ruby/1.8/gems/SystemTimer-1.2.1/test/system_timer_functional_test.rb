require File.dirname(__FILE__) + '/test_helper'

functional_tests do
  
  DEFAULT_ERROR_MARGIN = 2

  test "original_ruby_sigalrm_handler is nil after reset" do
    SystemTimer.send(:install_ruby_sigalrm_handler)
    SystemTimer.send(:reset_original_ruby_sigalrm_handler)
    assert_nil SystemTimer.send(:original_ruby_sigalrm_handler)
  end  
  
  test "original_ruby_sigalrm_handler is set to existing handler after " +
       "install_ruby_sigalrm_handler when save_previous_handler is true" do
    SystemTimer.expects(:trap).with('SIGALRM').returns(:an_existing_handler)
    SystemTimer.send(:install_ruby_sigalrm_handler)
    assert_equal :an_existing_handler, SystemTimer.send(:original_ruby_sigalrm_handler)
  end
  
  test "restore_original_ruby_sigalrm_handler traps sigalrm using original_ruby_sigalrm_handler" do
    SystemTimer.stubs(:original_ruby_sigalrm_handler).returns(:the_original_handler)
    SystemTimer.expects(:trap).with('SIGALRM', :the_original_handler)
    SystemTimer.send :restore_original_ruby_sigalrm_handler
  end  
  
  test "restore_original_ruby_sigalrm_handler resets original_ruby_sigalrm_handler" do
    SystemTimer.stubs(:trap)
    SystemTimer.expects(:reset_original_ruby_sigalrm_handler)
    SystemTimer.send :restore_original_ruby_sigalrm_handler
  end  
  
  test "restore_original_ruby_sigalrm_handler reset SIGALRM handler to default when original_ruby_sigalrm_handler is nil" do
    SystemTimer.stubs(:original_ruby_sigalrm_handler)
    SystemTimer.expects(:trap).with('SIGALRM', 'DEFAULT')
    SystemTimer.stubs(:reset_original_ruby_sigalrm_handler)
    SystemTimer.send :restore_original_ruby_sigalrm_handler
  end  
  
  test "restore_original_ruby_sigalrm_handler resets original_ruby_sigalrm_handler when trap raises" do
    SystemTimer.stubs(:trap).returns(:the_original_handler)
    SystemTimer.send(:install_ruby_sigalrm_handler)
    SystemTimer.expects(:trap).raises("next time maybe...")
    SystemTimer.expects(:reset_original_ruby_sigalrm_handler)
  
    SystemTimer.send(:restore_original_ruby_sigalrm_handler) rescue nil
  end  
  
  test "timeout_after raises TimeoutError if block takes too long" do
    assert_raises(Timeout::Error) do
      SystemTimer.timeout_after(1) {sleep 5}
    end
  end

  test "timeout_after timeout can be a fraction of a second" do
    assert_raises(Timeout::Error) do
      SystemTimer.timeout_after(0.2) {sleep 3}
    end
  end


  test "timeout_after raises a custom timeout when block takes too long and a custom exception class is provided" do
    ACustomException = Class.new(Exception)
    assert_raises(ACustomException) do
      SystemTimer.timeout_after(1, ACustomException) {sleep 5}
    end
  end
 
  test "timeout_after does not raises Timeout Error if block completes in time" do
    SystemTimer.timeout_after(5) {sleep 1}
  end
  
  test "timeout_after returns the value returned by the black" do
    assert_equal :block_value, SystemTimer.timeout_after(1) {:block_value}
  end
  
  test "timeout_after raises TimeoutError in thread that called timeout_after" do
    raised_thread = nil
    other_thread = Thread.new do 
      begin
        SystemTimer.timeout_after(1) {sleep 5}
        flunk "Should have timed out"
      rescue Timeout::Error
        raised_thread = Thread.current
      end
    end
    
    other_thread.join 
    assert_equal other_thread, raised_thread
  end
  
  test "cancelling a timer that was installed restores previous ruby handler for SIG_ALRM" do    
    begin
      fake_original_ruby_handler = proc {}
      initial_ruby_handler = trap "SIGALRM", fake_original_ruby_handler
      SystemTimer.install_first_timer_and_save_original_configuration 3
      SystemTimer.restore_original_configuration
      assert_equal fake_original_ruby_handler, trap("SIGALRM", "IGNORE")    
    ensure  # avoid interfering with test infrastructure
      trap("SIGALRM", initial_ruby_handler) if initial_ruby_handler  
    end
  end
   
  test "debug_enabled returns true after enabling debug" do
    begin
      SystemTimer.disable_debug
      SystemTimer.enable_debug
      assert_equal true, SystemTimer.debug_enabled?
    ensure
      SystemTimer.disable_debug
    end
  end 
  
  test "debug_enabled returns false after disable debug" do
    begin
      SystemTimer.enable_debug
      SystemTimer.disable_debug
      assert_equal false, SystemTimer.debug_enabled?
    ensure
      SystemTimer.disable_debug
    end 
  end
  
  test "timeout offers an API fully compatible with timeout.rb" do
    assert_raises(Timeout::Error) do
      SystemTimer.timeout(1) {sleep 5}
    end
  end

  # Disable this test as it is failing on Ubuntu. The problem is that
  # for some reason M.R.I 1.8 is trapping the Ruby signals at the
  # time the system SIGALRM is delivered, hence we do not timeout as
  # quickly as we should. Needs further investigation. At least the
  # SIGALRM ensures that the system will schedule M.R.I. native thread.
  #
  #  
  # test "while exact timeouts cannot be guaranted the timeout should not exceed the provided timeout by 2 seconds" do
  #   start = Time.now
  #   begin
  #     SystemTimer.timeout_after(2) do 
  #       open "http://www.invalid.domain.comz"
  #     end
  #     raise "should never get there"
  #   rescue SocketError => e
  #   rescue Timeout::Error => e
  #   end
  #   elapsed = Time.now - start
  #   assert elapsed < 4, "Got #{elapsed} s, expected 2, at most 4"
  # end
  
  
  test "timeout are enforced on system calls" do
    assert_timeout_within(3) do
      SystemTimer.timeout(3) do
         sleep 30
      end
    end
  end
  
  test "timeout work when spawning a different thread" do
    assert_timeout_within(3) do
      thread = Thread.new do
        SystemTimer.timeout(3) do
           sleep 60
        end
      end
      thread.join
    end
  end
  
  test "can set multiple serial timers" do
    10.times do |i|
      print(i) & STDOUT.flush
      assert_timeout_within(1) do
        SystemTimer.timeout(1) do
           sleep 60
        end
      end
    end
  end

  test "can set multiple serial timers with fractional timeout" do
    10.times do |i|
      print(i) & STDOUT.flush
      assert_timeout_within(0.5) do
        SystemTimer.timeout(0.5) do
           sleep 60
        end
      end
    end
  end
  
  test "timeout work when setting concurrent timers, the first one expiring before the second one" do
    first_thread = Thread.new do
      assert_timeout_within(3) do
        SystemTimer.timeout(3) do
           sleep 60
        end
      end
    end
    second_thread = Thread.new do
      assert_timeout_within(5) do
        SystemTimer.timeout(5) do
           sleep 60
        end
      end
    end
    first_thread.join
    second_thread.join
  end
  
  test "timeout work when setting concurrent timers, the second one expiring before the first one" do

    first_thread = Thread.new do
      assert_timeout_within(10) do
        SystemTimer.timeout(10) do
           sleep 60
        end
      end
    end
    second_thread = Thread.new do
      assert_timeout_within(3) do
        SystemTimer.timeout(3) do
           sleep 60
        end
      end
    end
    first_thread.join
    second_thread.join
  end
  
  test "timeout work when setting concurrent timers with the exact same timeout" do
         
    first_thread = Thread.new do
      assert_timeout_within(2) do
        SystemTimer.timeout(2) do
           sleep 60
        end
      end
    end
    second_thread = Thread.new do
      assert_timeout_within(2) do
        SystemTimer.timeout(2) do
           sleep 60
        end
      end
    end
    first_thread.join
    second_thread.join
  end

  test "timeout works with random concurrent timers dynamics" do
    all_threads = []
    
    10.times do
      a_timeout = [1, (rand(10)).to_f].max
      all_threads << Thread.new do
        assert_timeout_within(a_timeout, 10) do
          SystemTimer.timeout(a_timeout) do
             sleep 180
          end
        end
      end
    end
    
    all_threads.each {|t| t.join}
  end
  
  def assert_timeout_within(expected_timeout_in_seconds, 
                            error_margin = DEFAULT_ERROR_MARGIN, 
                            &block)                            
    start = Time.now    
    yield
    flunk "Did not timeout as expected!"
  rescue Timeout::Error    
    elapsed = Time.now - start
    assert elapsed >= expected_timeout_in_seconds, 
           "Timed out too early, expected #{expected_timeout_in_seconds}, got #{elapsed} s"
    assert elapsed < (expected_timeout_in_seconds + error_margin), 
           "Timed out after #{elapsed} seconds, expected #{expected_timeout_in_seconds}"
  end
  
end
