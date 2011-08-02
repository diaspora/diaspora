require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', '..', 'test_helper'))
require 'new_relic/agent/instrumentation/metric_frame/pop'
class NewRelic::Agent::Instrumentation::MetricFrame::PopTest < Test::Unit::TestCase
  include NewRelic::Agent::Instrumentation::MetricFrame::Pop

  attr_reader :agent
  attr_reader :transaction_sampler

  def setup
    @agent = mock('agent')
    @transaction_sampler = mock('transaction sampler')
  end

  def teardown
    Thread.current[:newrelic_start_time] = nil
    Thread.current[:newrelic_metric_frame] = nil
  end

  def test_clear_thread_metric_frame
    Thread.current[:newrelic_metric_frame] = 'whee'
    clear_thread_metric_frame!
    assert_equal nil, Thread.current[:newrelic_metric_frame], 'should nil out the thread var'
  end

  def test_set_new_scope
    fakeagent = mock('agent')
    self.expects(:agent).returns(fakeagent)
    fakeengine = mock('stats_engine')
    fakeagent.expects(:stats_engine).returns(fakeengine)
    fakeengine.expects(:scope_name=).with('A METRIC')

    set_new_scope!('A METRIC')
  end

  def test_log_underflow
    NewRelic::Agent.logger.expects(:error).with(regexp_matches(/Underflow in metric frames: /))
    log_underflow
  end

  def test_notice_scope_empty
    transaction_sampler.expects(:notice_scope_empty)
    notice_scope_empty
  end

  def test_record_transaction_cpu_positive
    self.expects(:cpu_burn).once.returns(1.0)
    transaction_sampler.expects(:notice_transaction_cpu_time).with(1.0)
    record_transaction_cpu
  end

  def test_record_transaction_cpu_negative
    self.expects(:cpu_burn).once.returns(nil)
    # should not be called for the nil case
    transaction_sampler.expects(:notice_transaction_cpu_time).never
    record_transaction_cpu
  end

  def test_normal_cpu_burn_positive
    @process_cpu_start = 3
    self.expects(:process_cpu).returns(4)
    assert_equal 1, normal_cpu_burn
  end

  def test_normal_cpu_burn_negative
    @process_cpu_start = nil
    self.expects(:process_cpu).never
    assert_equal nil, normal_cpu_burn
  end

  def test_jruby_cpu_burn_positive
    @jruby_cpu_start = 3
    self.expects(:jruby_cpu_time).returns(4)
    self.expects(:record_jruby_cpu_burn).with(1)
    assert_equal 1, jruby_cpu_burn
  end

  def test_jruby_cpu_burn_negative
    @jruby_cpu_start = nil
    self.expects(:jruby_cpu_time).never
    self.expects(:record_jruby_cpu_burn).never
    assert_equal nil, jruby_cpu_burn
  end

  def test_record_jruby_cpu_burn
    NewRelic::Agent.get_stats_no_scope(NewRelic::Metrics::USER_TIME).expects(:record_data_point).with(1.0)
    record_jruby_cpu_burn(1.0)
  end

  def test_cpu_burn_normal
    self.expects(:normal_cpu_burn).returns(1)
    self.expects(:jruby_cpu_burn).never
    assert_equal 1, cpu_burn
  end

  def test_cpu_burn_jruby
    self.expects(:normal_cpu_burn).returns(nil)
    self.expects(:jruby_cpu_burn).returns(2)
    assert_equal 2, cpu_burn
  end

  def test_end_transaction
    fake_stats_engine = mock('stats engine')
    agent.expects(:stats_engine).returns(fake_stats_engine)
    fake_stats_engine.expects(:end_transaction)
    end_transaction!
  end

  def test_notify_transaction_sampler_true
    self.expects(:record_transaction_cpu)
    self.expects(:notice_scope_empty)
    notify_transaction_sampler(true)
  end

  def test_notify_transaction_sampler_false
    self.expects(:record_transaction_cpu)
    self.expects(:notice_scope_empty)
    notify_transaction_sampler(false)
  end

  def test_traced
    NewRelic::Agent.expects(:is_execution_traced?)
    traced?
  end

  def test_handle_empty_path_stack_default
    @path_stack = [] # it is empty
    self.expects(:traced?).returns(true)
    fakemetric = mock('metric')
    fakemetric.expects(:is_web_transaction?).returns(true)
    self.expects(:notify_transaction_sampler).with(true)
    self.expects(:end_transaction!)
    self.expects(:clear_thread_metric_frame!)
    handle_empty_path_stack(fakemetric)
  end

  def test_handle_empty_path_stack_non_web
    @path_stack = [] # it is empty
    self.expects(:traced?).returns(true)
    fakemetric = mock('metric')
    fakemetric.expects(:is_web_transaction?).returns(false)
    self.expects(:notify_transaction_sampler).with(false)
    self.expects(:end_transaction!)
    self.expects(:clear_thread_metric_frame!)
    handle_empty_path_stack(fakemetric)
  end

  def test_handle_empty_path_stack_error
    @path_stack = ['not empty']
    assert_raise(RuntimeError) do
      handle_empty_path_stack(mock('metric'))
    end
  end

  def test_handle_empty_path_stack_untraced
    @path_stack = [] # it is empty
    self.expects(:traced?).returns(false)
    fakemetric = mock('metric')
    fakemetric.expects(:is_web_transaction?).never
    self.expects(:end_transaction!)
    self.expects(:clear_thread_metric_frame!)
    handle_empty_path_stack(fakemetric)
  end

  def test_current_stack_metric
    self.expects(:metric_name)
    current_stack_metric
  end
end

