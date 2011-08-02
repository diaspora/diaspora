require File.expand_path(File.join(File.dirname(__FILE__),'..','..','test_helper'))
require 'new_relic/agent/mock_scope_listener'

class Module
  def method_traced?(method_name, metric_name)
    traced_method_prefix = _traced_method_name(method_name, metric_name)

    method_defined? traced_method_prefix
  end
end

class Insider
  def initialize(stats_engine)
    @stats_engine = stats_engine
  end
  def catcher(level=0)
    thrower(level) if level>0
  end
  def thrower(level)
    if level == 0
      # don't use a real sampler because we can't instantiate one
      # sampler = NewRelic::Agent::TransactionSampler.new(NewRelic::Agent.instance)
      sampler = "<none>"
      begin
        @stats_engine.transaction_sampler = sampler
        fail "This should not have worked."
        rescue; end
    else
      thrower(level-1)
    end
  end
end

module NewRelic
  module Agent
    extend self
    def module_method_to_be_traced (x, testcase)
      testcase.assert x == "x"
      testcase.assert testcase.stats_engine.peek_scope.name == "x"
    end
  end
end

module TestModuleWithLog
  extend self
  def other_method
    #just here to be traced
    log "12345"
  end

  def log( msg )
    msg
  end
  include NewRelic::Agent::MethodTracer
  add_method_tracer :other_method, 'Custom/foo/bar'
end

class NewRelic::Agent::MethodTracerTest < Test::Unit::TestCase
  attr_reader :stats_engine

  def setup
    NewRelic::Agent.manual_start
    @stats_engine = NewRelic::Agent.instance.stats_engine
    @stats_engine.clear_stats
    @scope_listener = NewRelic::Agent::MockScopeListener.new
    @old_sampler = NewRelic::Agent.instance.transaction_sampler
    @stats_engine.transaction_sampler = @scope_listener
    super
  end

  def teardown
    @stats_engine.transaction_sampler = @old_sampler
    @stats_engine.clear_stats
    begin
      self.class.remove_method_tracer :method_to_be_traced, @metric_name if @metric_name
    rescue RuntimeError
      # ignore 'no tracer' errors from remove method tracer
    end

    @metric_name = nil
    super
  end

  def test_preserve_logging
    assert_equal '12345', TestModuleWithLog.other_method
  end

  def test_basic
    metric = "hello"
    t1 = Time.now
    self.class.trace_execution_scoped metric do
      sleep 0.05
      assert metric == @stats_engine.peek_scope.name
    end
    elapsed = Time.now - t1

    stats = @stats_engine.get_stats(metric)
    check_time stats.total_call_time, elapsed
    assert stats.call_count == 1
  end

  def test_basic__original_api
    metric = "hello"
    t1 = Time.now
    self.class.trace_method_execution metric, true, true, true do
      sleep 0.05
      assert metric == @stats_engine.peek_scope.name
    end
    elapsed = Time.now - t1

    stats = @stats_engine.get_stats(metric)
    check_time stats.total_call_time, elapsed
    assert stats.call_count == 1
  end

  METRIC = "metric"
  def test_add_method_tracer
    @metric_name = METRIC
    self.class.add_method_tracer :method_to_be_traced, METRIC

    t1 = Time.now
    method_to_be_traced 1,2,3,true,METRIC
    elapsed = Time.now - t1

    begin
      self.class.remove_method_tracer :method_to_be_traced, METRIC
    rescue RuntimeError
      # ignore 'no tracer' errors from remove method tracer
    end


    stats = @stats_engine.get_stats(METRIC)
    check_time stats.total_call_time, elapsed
    assert stats.call_count == 1
  end

  def test_add_method_tracer__default
    self.class.add_method_tracer :simple_method

    simple_method

    stats = @stats_engine.get_stats("Custom/#{self.class.name}/simple_method")
    assert stats.call_count == 1

  end
  def test_add_method_tracer__reentry
    self.class.add_method_tracer :simple_method
    self.class.add_method_tracer :simple_method
    self.class.add_method_tracer :simple_method

    simple_method

    stats = @stats_engine.get_stats("Custom/#{self.class.name}/simple_method")
    assert stats.call_count == 1
  end

  def test_method_traced?
    assert !self.class.method_traced?(:method_to_be_traced, METRIC)
    self.class.add_method_tracer :method_to_be_traced, METRIC
    assert self.class.method_traced?(:method_to_be_traced, METRIC)
    begin
      self.class.remove_method_tracer :method_to_be_traced, METRIC
    rescue RuntimeError
      # ignore 'no tracer' errors from remove method tracer
    end
  end

  def test_tt_only

    assert_nil @scope_listener.scope["c2"]
    self.class.add_method_tracer :method_c1, "c1", :push_scope => true

    self.class.add_method_tracer :method_c2, "c2", :metric => false
    self.class.add_method_tracer :method_c3, "c3", :push_scope => false

    method_c1

    assert_not_nil @stats_engine.lookup_stats("c1")
    assert_nil @stats_engine.lookup_stats("c2")
    assert_not_nil @stats_engine.lookup_stats("c3")

    assert_not_nil @scope_listener.scope["c2"]
  end

  def test_nested_scope_tracer
    Insider.add_method_tracer :catcher, "catcher", :push_scope => true
    Insider.add_method_tracer :thrower, "thrower", :push_scope => true
    sampler = NewRelic::Agent.instance.transaction_sampler
    mock = Insider.new(@stats_engine)
    mock.catcher(0)
    mock.catcher(5)
    stats = @stats_engine.get_stats("catcher")
    assert_equal 2, stats.call_count
    stats = @stats_engine.get_stats("thrower")
    assert_equal 6, stats.call_count
    sample = sampler.harvest
    assert_not_nil sample
  end

  def test_add_same_tracer_twice
    @metric_name = METRIC
    self.class.add_method_tracer :method_to_be_traced, METRIC
    self.class.add_method_tracer :method_to_be_traced, METRIC

    t1 = Time.now
    method_to_be_traced 1,2,3,true,METRIC
    elapsed = Time.now - t1

    begin
      self.class.remove_method_tracer :method_to_be_traced, METRIC
    rescue RuntimeError
      # ignore 'no tracer' errors from remove method tracer
    end

    stats = @stats_engine.get_stats(METRIC)
    check_time stats.total_call_time, elapsed
    assert stats.call_count == 1
  end

  def test_add_tracer_with_dynamic_metric
    metric_code = '#{args[0]}.#{args[1]}'
    @metric_name = metric_code
    expected_metric = "1.2"
    self.class.add_method_tracer :method_to_be_traced, metric_code

    t1 = Time.now
    method_to_be_traced 1,2,3,true,expected_metric
    elapsed = Time.now - t1

    begin
      self.class.remove_method_tracer :method_to_be_traced, metric_code
    rescue RuntimeError
      # ignore 'no tracer' errors from remove method tracer
    end

    stats = @stats_engine.get_stats(expected_metric)
    check_time stats.total_call_time, elapsed
    assert stats.call_count == 1
  end

  def test_trace_method_with_block
    self.class.add_method_tracer :method_with_block, METRIC

    t1 = Time.now
    method_with_block(1,2,3,true,METRIC) do |scope|
      assert scope == METRIC
    end
    elapsed = Time.now - t1

    stats = @stats_engine.get_stats(METRIC)
    check_time stats.total_call_time, elapsed
    assert stats.call_count == 1
  end

  def test_trace_module_method
    NewRelic::Agent.add_method_tracer :module_method_to_be_traced, '#{args[0]}'
    NewRelic::Agent.module_method_to_be_traced "x", self
    NewRelic::Agent.remove_method_tracer :module_method_to_be_traced, '#{args[0]}'
  end

  def test_remove
    self.class.add_method_tracer :method_to_be_traced, METRIC
    self.class.remove_method_tracer :method_to_be_traced, METRIC

    t1 = Time.now
    method_to_be_traced 1,2,3,false,METRIC
    elapsed = Time.now - t1

    stats = @stats_engine.get_stats(METRIC)
    assert stats.call_count == 0
  end

  def self.static_method(x, testcase, is_traced)
    testcase.assert x == "x"
    testcase.assert((testcase.stats_engine.peek_scope.name == "x") == is_traced)
  end

  def trace_trace_static_method
    self.add_method_tracer :static_method, '#{args[0]}'
    self.class.static_method "x", self, true
    self.remove_method_tracer :static_method, '#{args[0]}'
    self.class.static_method "x", self, false
  end

  def test_multiple_metrics__scoped
    metrics = %w[first second third]
    self.class.trace_execution_scoped metrics do
      sleep 0.05
    end
    elapsed = @stats_engine.get_stats('first').average_call_time
    metrics.map{|name| @stats_engine.get_stats name}.each do | m |
      assert_equal 1, m.call_count
      assert_equal elapsed, m.total_call_time
    end
  end
  def test_multiple_metrics__unscoped
    metrics = %w[first second third]
    self.class.trace_execution_unscoped metrics do
      sleep 0.05
    end
    elapsed = @stats_engine.get_stats('first').average_call_time
    metrics.map{|name| @stats_engine.get_stats name}.each do | m |
      assert_equal 1, m.call_count
      assert_equal elapsed, m.total_call_time
    end
  end
  def test_exception
    begin
      metric = "hey"
      self.class.trace_execution_scoped metric do
        assert @stats_engine.peek_scope.name == metric
        throw Exception.new
      end

      assert false # should never get here
    rescue Exception
      # make sure the scope gets popped
      assert @stats_engine.peek_scope == nil
    end

    stats = @stats_engine.get_stats metric
    assert stats.call_count == 1
  end

  def test_add_multiple_tracers
    self.class.add_method_tracer :method_to_be_traced, 'X', :push_scope => false
    method_to_be_traced 1,2,3,true,nil
    self.class.add_method_tracer :method_to_be_traced, 'Y'
    method_to_be_traced 1,2,3,true,'Y'
    self.class.remove_method_tracer :method_to_be_traced, 'Y'
    method_to_be_traced 1,2,3,true,nil
    self.class.remove_method_tracer :method_to_be_traced, 'X'
    method_to_be_traced 1,2,3,false,'X'
  end

  def trace_no_push_scope
    self.class.add_method_tracer :method_to_be_traced, 'X', :push_scope => false
    method_to_be_traced 1,2,3,true,nil
    self.class.remove_method_tracer :method_to_be_traced, 'X'
    method_to_be_traced 1,2,3,false,'X'
  end

  def check_time(t1, t2)
    assert_in_delta t2, t1, 0.05
  end

  # =======================================================
  # test methods to be traced
  def method_to_be_traced(x, y, z, is_traced, expected_metric)
    sleep 0.01
    assert x == 1
    assert y == 2
    assert z == 3
    scope_name = @stats_engine.peek_scope ? @stats_engine.peek_scope.name : nil
    if is_traced
      assert_equal expected_metric, scope_name
    else
      assert_not_equal expected_metric, scope_name
    end
  end

  def method_with_block(x, y, z, is_traced, expected_metric, &block)
    sleep 0.01
    assert x == 1
    assert y == 2
    assert z == 3
    block.call(@stats_engine.peek_scope.name)

    scope_name = @stats_engine.peek_scope ? @stats_engine.peek_scope.name : nil
    assert((expected_metric == scope_name) == is_traced)
  end

  def method_c1
    method_c2
  end

  def method_c2
    method_c3
  end

  def method_c3
  end

  def simple_method
  end
end
