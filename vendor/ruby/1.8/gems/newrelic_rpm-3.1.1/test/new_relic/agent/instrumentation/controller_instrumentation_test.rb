require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'test_helper'))
class NewRelic::Agent::Instrumentation::ControllerInstrumentationTest < Test::Unit::TestCase
  require 'new_relic/agent/instrumentation/controller_instrumentation'
  class TestObject
    include NewRelic::Agent::Instrumentation::ControllerInstrumentation
  end

  def test_detect_upstream_wait_basic
    start_time = Time.now
    object = TestObject.new
    # should return the start time above by default
    object.expects(:newrelic_request_headers).returns({:request => 'headers'}).twice
    object.expects(:parse_frontend_headers).with({:request => 'headers'}).returns(start_time)
    assert_equal(start_time, object.send(:_detect_upstream_wait, start_time))
    assert_equal(0.0, Thread.current[:newrelic_queue_time])
  end

  def test_detect_upstream_wait_with_upstream
    start_time = Time.now
    runs_at = start_time + 1
    object = TestObject.new
    object.expects(:newrelic_request_headers).returns(true).twice
    object.expects(:parse_frontend_headers).returns(start_time)
    assert_equal(start_time, object.send(:_detect_upstream_wait, runs_at))
    assert_equal(1.0, Thread.current[:newrelic_queue_time])
  end

  def test_detect_upstream_wait_swallows_errors
    start_time = Time.now
    object = TestObject.new
    # should return the start time above when an error is raised
    object.expects(:newrelic_request_headers).returns({:request => 'headers'}).twice
    object.expects(:parse_frontend_headers).with({:request => 'headers'}).raises("an error")
    assert_equal(start_time, object.send(:_detect_upstream_wait, start_time))
  end
end
