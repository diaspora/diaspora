require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'test_helper'))

class NewRelic::Agent::Instrumentation::TaskInstrumentationTest < Test::Unit::TestCase
  include NewRelic::Agent::Instrumentation::ControllerInstrumentation
  extend TestContexts
  attr_accessor :agent

  with_running_agent do

    should "run" do
      run_task_inner 0
      stat_names = %w[Controller/NewRelic::Agent::Instrumentation::TaskInstrumentationTest/inner_task_0
                    HttpDispatcher
                    Apdex Apdex/NewRelic::Agent::Instrumentation::TaskInstrumentationTest/inner_task_0].sort
      expected_but_missing = stat_names - @agent.stats_engine.metrics
      assert_equal 0, expected_but_missing.size, @agent.stats_engine.metrics.map  { |n|
        stat = @agent.stats_engine.get_stats_no_scope(n)
      "#{'%-26s' % n}: #{stat.call_count} calls @ #{stat.average_call_time} sec/call"
      }.join("\n  ") + "\nmissing: #{expected_but_missing.inspect}"
      assert_equal 0, @agent.stats_engine.get_stats_no_scope('Controller').call_count
      assert_equal 1, @agent.stats_engine.get_stats_no_scope('Controller/NewRelic::Agent::Instrumentation::TaskInstrumentationTest/inner_task_0').call_count
    end

    should "run_recursive" do
      run_task_inner(3)
      assert_equal 1, @agent.stats_engine.lookup_stats(
                          'Controller/NewRelic::Agent::Instrumentation::TaskInstrumentationTest/inner_task_0',
                          'Controller/NewRelic::Agent::Instrumentation::TaskInstrumentationTest/inner_task_1').call_count
      assert_equal 1, @agent.stats_engine.lookup_stats(
                          'Controller/NewRelic::Agent::Instrumentation::TaskInstrumentationTest/inner_task_1',
                          'Controller/NewRelic::Agent::Instrumentation::TaskInstrumentationTest/inner_task_2').call_count
      assert_equal 1, @agent.stats_engine.lookup_stats(
                          'Controller/NewRelic::Agent::Instrumentation::TaskInstrumentationTest/inner_task_2',
                          'Controller/NewRelic::Agent::Instrumentation::TaskInstrumentationTest/inner_task_3').call_count
      assert_equal 1, @agent.stats_engine.get_stats_no_scope('Controller/NewRelic::Agent::Instrumentation::TaskInstrumentationTest/inner_task_0').call_count
      assert_equal 1, @agent.stats_engine.get_stats_no_scope('Controller/NewRelic::Agent::Instrumentation::TaskInstrumentationTest/inner_task_1').call_count
      assert_equal 1, @agent.stats_engine.get_stats_no_scope('Controller/NewRelic::Agent::Instrumentation::TaskInstrumentationTest/inner_task_2').call_count
      assert_equal 1, @agent.stats_engine.get_stats_no_scope('Controller/NewRelic::Agent::Instrumentation::TaskInstrumentationTest/inner_task_3').call_count
      assert_equal 0, @agent.stats_engine.get_stats_no_scope('Controller').call_count
    end

    should "run_nested" do
      run_task_outer(3)
      @agent.stats_engine.metrics.sort.each do |n|
        stat = @agent.stats_engine.get_stats_no_scope(n)
        #      puts "#{'%-26s' % n}: #{stat.call_count} calls @ #{stat.average_call_time} sec/call"
      end
      assert_equal 1, @agent.stats_engine.get_stats_no_scope('Controller/NewRelic::Agent::Instrumentation::TaskInstrumentationTest/outer_task').call_count
      assert_equal 2, @agent.stats_engine.get_stats_no_scope('Controller/NewRelic::Agent::Instrumentation::TaskInstrumentationTest/inner_task_0').call_count
    end

    should "reentrancy" do
      assert_equal 0, NewRelic::Agent::BusyCalculator.busy_count
      run_task_inner(1)
      assert_equal 1, @agent.stats_engine.get_stats_no_scope('Controller/NewRelic::Agent::Instrumentation::TaskInstrumentationTest/inner_task_0').call_count
      assert_equal 1, @agent.stats_engine.get_stats_no_scope('Controller/NewRelic::Agent::Instrumentation::TaskInstrumentationTest/inner_task_1').call_count
      compare_metrics %w[
      Controller/NewRelic::Agent::Instrumentation::TaskInstrumentationTest/inner_task_0:Controller/NewRelic::Agent::Instrumentation::TaskInstrumentationTest/inner_task_1
      Controller/NewRelic::Agent::Instrumentation::TaskInstrumentationTest/inner_task_0
      Controller/NewRelic::Agent::Instrumentation::TaskInstrumentationTest/inner_task_1
      ], @agent.stats_engine.metrics.grep(/^Controller/)
    end

    should "transaction" do
      assert_equal 0, @agent.transaction_sampler.scope_depth, "existing unfinished sample"
      assert_nil @agent.transaction_sampler.last_sample
      assert_equal @agent.transaction_sampler, @agent.stats_engine.instance_variable_get("@transaction_sampler")
      run_task_outer(10)
      assert_equal 0, @agent.transaction_sampler.scope_depth, "existing unfinished sample"
      @agent.stats_engine.metrics.sort.each do |n|
        stat = @agent.stats_engine.get_stats_no_scope(n)
        #      puts "#{'%-26s' % n}: #{stat.call_count} calls @ #{stat.average_call_time} sec/call"
      end
      assert_equal 1, @agent.stats_engine.get_stats_no_scope('Controller/NewRelic::Agent::Instrumentation::TaskInstrumentationTest/outer_task').call_count
      assert_equal 0, @agent.stats_engine.get_stats_no_scope('Controller').call_count
      assert_equal 2, @agent.stats_engine.get_stats_no_scope('Controller/NewRelic::Agent::Instrumentation::TaskInstrumentationTest/inner_task_0').call_count
      assert_equal 0, @agent.transaction_sampler.scope_depth, "existing unfinished sample"
      sample = @agent.transaction_sampler.last_sample
      assert_not_nil sample
      assert_not_nil sample.params[:cpu_time], "cpu time nil: \n#{sample}"
      assert sample.params[:cpu_time] >= 0, "cpu time: #{sample.params[:cpu_time]},\n#{sample}"
      assert_equal '10', sample.params[:request_params][:level]
    end

    should "abort" do
      @acct = 'Redrocks'
      perform_action_with_newrelic_trace(:name => 'hello', :force => true, :params => { :account => @acct}) do
        self.class.inspect
        NewRelic::Agent.abort_transaction!
      end
      # We record the controller metric still, but abort any transaction recording.
      assert_equal 1, @agent.stats_engine.get_stats_no_scope('Controller/NewRelic::Agent::Instrumentation::TaskInstrumentationTest/hello').call_count
      assert_nil @agent.transaction_sampler.last_sample
    end
    should "block" do
      assert_equal @agent, NewRelic::Agent.instance
      @acct = 'Redrocks'
      perform_action_with_newrelic_trace(:name => 'hello', :force => true, :params => { :account => @acct}) do
        self.class.inspect
      end
      @agent.stats_engine.metrics.sort.each do |n|
        stat = @agent.stats_engine.get_stats_no_scope(n)
        #puts "#{'%-26s' % n}: #{stat.call_count} calls @ #{stat.average_call_time} sec/call"
      end
      assert_equal @agent, NewRelic::Agent.instance
      assert_equal 1, @agent.stats_engine.get_stats_no_scope('Controller/NewRelic::Agent::Instrumentation::TaskInstrumentationTest/hello').call_count
      sample = @agent.transaction_sampler.last_sample
      assert_not_nil sample
      assert_equal 'Redrocks', sample.params[:request_params][:account]

    end

    should "error_handling" do
      @agent.error_collector.ignore_error_filter
      @agent.error_collector.harvest_errors([])
      @agent.error_collector.expects(:notice_error).once
      assert_equal @agent.error_collector, NewRelic::Agent.instance.error_collector
      assert_raise RuntimeError do
        run_task_exception
      end
    end

    should "custom_params" do
      @agent.error_collector.stubs(:enabled).returns(true)
      @agent.error_collector.ignore_error_filter
      @agent.error_collector.harvest_errors([])
      assert_equal @agent.error_collector, NewRelic::Agent.instance.error_collector
      assert_raise RuntimeError do
        run_task_exception
      end
      errors = @agent.error_collector.harvest_errors([])
      assert_equal 1, errors.size
      error = errors.first
      assert_equal "Controller/NewRelic::Agent::Instrumentation::TaskInstrumentationTest/run_task_exception", error.path
      assert_not_nil error.params[:stack_trace]
      assert_not_nil error.params[:custom_params]
    end

    should "instrument_bg" do
      run_background_job
      stat_names = %w[OtherTransaction/Background/NewRelic::Agent::Instrumentation::TaskInstrumentationTest/run_background_job
                    OtherTransaction/Background/all
                    OtherTransaction/all].sort

      expected_but_missing = stat_names - @agent.stats_engine.metrics
      assert_equal 0, expected_but_missing.size, @agent.stats_engine.metrics.map  { |n|
        stat = @agent.stats_engine.get_stats_no_scope(n)
      "#{'%-26s' % n}: #{stat.call_count} calls @ #{stat.average_call_time} sec/call"
      }.join("\n  ") + "\nmissing: #{expected_but_missing.inspect}"
      assert_equal 1, @agent.stats_engine.get_stats_no_scope('OtherTransaction/all').call_count
      assert_equal 1, @agent.stats_engine.get_stats_no_scope('OtherTransaction/Background/all').call_count
    end
  end

  private

  def run_task_inner(n)
    return if n == 0
    assert_equal 1, NewRelic::Agent::BusyCalculator.busy_count
    run_task_inner(n-1)
  end

  def run_task_outer(n=0)
    assert_equal 1, NewRelic::Agent::BusyCalculator.busy_count
    run_task_inner(n)
    run_task_inner(n)
  end

  def run_task_exception
    NewRelic::Agent.add_custom_parameters(:custom_one => 'one custom val')
    assert_equal 1, NewRelic::Agent::BusyCalculator.busy_count
    raise "This is an error"
  end

  def run_background_job
    "This is a background job"
  end

  add_transaction_tracer :run_task_exception
  add_transaction_tracer :run_task_inner, :name => 'inner_task_#{args[0]}'
  add_transaction_tracer :run_task_outer, :name => 'outer_task', :params => '{ :level => args[0] }'
  # Eventually we need th change this to :category => :task
  add_transaction_tracer :run_background_job, :category => 'OtherTransaction/Background'
end
