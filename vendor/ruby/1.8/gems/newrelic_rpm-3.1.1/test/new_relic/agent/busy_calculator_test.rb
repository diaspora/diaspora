# Run faster standalone
ENV['SKIP_RAILS'] = 'true'
require File.expand_path(File.join(File.dirname(__FILE__),'..','..','test_helper'))
class NewRelic::Agent::BusyCalculatorTest < Test::Unit::TestCase
  attr_reader :now
  def setup
    @now = Time.now.to_f
    NewRelic::Agent::BusyCalculator.reset
    @instance_busy = NewRelic::MethodTraceStats.new
    NewRelic::Agent::BusyCalculator.stubs(:instance_busy_stats).returns(@instance_busy)
  end

  def test_normal
    # start the timewindow 10 seconds ago
    # start a request at 10 seconds, 5 seconds long
    NewRelic::Agent::BusyCalculator.stubs(:harvest_start).returns(now - 10.0)
    NewRelic::Agent::BusyCalculator.dispatcher_start(now - 10.0)
    NewRelic::Agent::BusyCalculator.dispatcher_finish(now - 5.0)
    assert_equal 5, NewRelic::Agent::BusyCalculator.accumulator
    NewRelic::Agent::BusyCalculator.harvest_busy

    assert_equal 1, @instance_busy.call_count
    assert_in_delta 0.50, @instance_busy.total_call_time, 0.05
  end
  def test_split
    # start the timewindow 10 seconds ago
    # start a request at 5 seconds, don't finish
    NewRelic::Agent::BusyCalculator.stubs(:harvest_start).returns(now - 10.0)
    NewRelic::Agent::BusyCalculator.dispatcher_start(now - 5.0)
    NewRelic::Agent::BusyCalculator.harvest_busy

    assert_equal 1, @instance_busy.call_count, @instance_busy
    assert_in_delta 0.50, @instance_busy.total_call_time, 0.05
  end
  def test_reentrancy
    # start the timewindow 10 seconds ago
    # start a request at 5 seconds, don't finish, but make two more
    # complete calls, which should be ignored.
    NewRelic::Agent::BusyCalculator.stubs(:harvest_start).returns(now - 10.0)
    NewRelic::Agent::BusyCalculator.dispatcher_start(now - 5.0)
    NewRelic::Agent::BusyCalculator.dispatcher_start(now - 4.5)
    NewRelic::Agent::BusyCalculator.dispatcher_start(now - 4.0)
    NewRelic::Agent::BusyCalculator.dispatcher_finish(now - 3.5)
    NewRelic::Agent::BusyCalculator.dispatcher_finish(now - 3.0)
    NewRelic::Agent::BusyCalculator.dispatcher_start(now - 2.0)
    NewRelic::Agent::BusyCalculator.dispatcher_finish(now - 1.0)
    NewRelic::Agent::BusyCalculator.harvest_busy

    assert_equal 1, @instance_busy.call_count
    assert_in_delta 0.50, @instance_busy.total_call_time, 0.05
  end
  def test_concurrency
    # start the timewindow 10 seconds ago
    # start a request at 10 seconds, 5 seconds long
    NewRelic::Agent::BusyCalculator.stubs(:harvest_start).returns(now - 10.0)
    NewRelic::Agent::BusyCalculator.dispatcher_start(now - 8.0)
    worker = Thread.new do
      # Get busy for 6 - 3 seconds
      NewRelic::Agent::BusyCalculator.dispatcher_start(now - 6.0)
      NewRelic::Agent::BusyCalculator.dispatcher_start(now - 5.0)
      NewRelic::Agent::BusyCalculator.dispatcher_finish(now - 4.0)
      NewRelic::Agent::BusyCalculator.dispatcher_finish(now - 3.0)
    end
    # Get busy for 8 - 2 seconds
    NewRelic::Agent::BusyCalculator.dispatcher_finish(now - 2.0)
    worker.join
    NewRelic::Agent::BusyCalculator.harvest_busy

    assert_equal 1, @instance_busy.call_count
    # 3 + 6 = 9, or 90%
    assert_in_delta 0.90, @instance_busy.total_call_time, 0.1

  end
  def test_dont_ignore_zero_counts
    assert_equal 0, @instance_busy.call_count, "Problem with test--instance busy not starting off at zero."
    NewRelic::Agent::BusyCalculator.harvest_busy
    NewRelic::Agent::BusyCalculator.harvest_busy
    NewRelic::Agent::BusyCalculator.harvest_busy
    assert_equal 3, @instance_busy.call_count
  end
end
