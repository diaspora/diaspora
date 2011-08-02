require File.expand_path(File.join(File.dirname(__FILE__),'..','test_helper'))
module NewRelic
  class MainAgentTest < Test::Unit::TestCase
    
    # mostly this module just passes through to the active agent
    # through the agent method or the control instance through
    # NewRelic::Control.instance . But it's nice to make sure.

    def teardown
      super
      Thread.current[:newrelic_untraced] = nil
    end
    
    def test_shutdown
      mock_agent = mocked_agent
      mock_agent.expects(:shutdown).with({})
      NewRelic::Agent.shutdown
    end

    def test_after_fork
      mock_agent = mocked_agent
      mock_agent.expects(:after_fork).with({})
      NewRelic::Agent.after_fork
    end
    
    def test_reset_stats
      mock_agent = mocked_agent
      mock_agent.expects(:reset_stats)
      NewRelic::Agent.reset_stats
    end

    def test_manual_start_default
      mock_control = mocked_control
      mock_control.expects(:init_plugin).with({:agent_enabled => true, :sync_startup => true})
      NewRelic::Agent.manual_start
    end
    
    def test_manual_start_with_opts
      mock_control = mocked_control
      mock_control.expects(:init_plugin).with({:agent_enabled => true, :sync_startup => false})
      NewRelic::Agent.manual_start(:sync_startup => false)
    end

    def test_logger
      control = mocked_control
      control.expects(:log)
      NewRelic::Agent.logger
    end

    def test_browser_timing_header
      agent = mocked_agent
      agent.expects(:browser_timing_header)
      NewRelic::Agent.browser_timing_header
    end

    def test_browser_timing_footer
      agent = mocked_agent
      agent.expects(:browser_timing_footer)
      NewRelic::Agent.browser_timing_footer
    end

    def test_get_stats
      agent = mocked_agent
      mock_stats_engine = mock('stats_engine')
      agent.expects(:stats_engine).returns(mock_stats_engine)
      mock_stats_engine.expects(:get_stats).with('Custom/test/metric', false)
      NewRelic::Agent.get_stats('Custom/test/metric')
    end
    
    # note that this is the same as get_stats above, they're just aliases
    def test_get_stats_no_scope
      agent = mocked_agent
      mock_stats_engine = mock('stats_engine')
      agent.expects(:stats_engine).returns(mock_stats_engine)
      mock_stats_engine.expects(:get_stats).with('Custom/test/metric', false)
      NewRelic::Agent.get_stats_no_scope('Custom/test/metric')
    end

    def test_agent_not_started
      old_agent = NewRelic::Agent.agent
      NewRelic::Agent.instance_eval { @agent = nil }
      assert_raise(RuntimeError) do
        NewRelic::Agent.agent
      end
      NewRelic::Agent.instance_eval { @agent = old_agent }
    end

    def test_agent_when_started
      old_agent = NewRelic::Agent.agent
      NewRelic::Agent.instance_eval { @agent = 'not nil' }
      assert_equal('not nil', NewRelic::Agent.agent, "should return the value from @agent")
      NewRelic::Agent.instance_eval { @agent = old_agent }
    end

    def test_abort_transaction_bang
      NewRelic::Agent::Instrumentation::MetricFrame.expects(:abort_transaction!)
      NewRelic::Agent.abort_transaction!
    end

    def test_is_transaction_traced_true
      Thread.current[:record_tt] = true
      assert_equal(true, NewRelic::Agent.is_transaction_traced?, 'should be true since the thread local is set')
    end

    def test_is_transaction_traced_blank
      Thread.current[:record_tt] = nil
      assert_equal(true, NewRelic::Agent.is_transaction_traced?, 'should be true since the thread local is not set')
    end

    def test_is_transaction_traced_false
      Thread.current[:record_tt] = false
      assert_equal(false, NewRelic::Agent.is_transaction_traced?, 'should be false since the thread local is false')
    end
    
    def test_is_sql_recorded_true
      Thread.current[:record_sql] = true
      assert_equal(true, NewRelic::Agent.is_sql_recorded?, 'should be true since the thread local is set')
    end

    def test_is_sql_recorded_blank
      Thread.current[:record_sql] = nil
      assert_equal(true, NewRelic::Agent.is_sql_recorded?, 'should be true since the thread local is not set')
    end

    def test_is_sql_recorded_false
      Thread.current[:record_sql] = false
      assert_equal(false, NewRelic::Agent.is_sql_recorded?, 'should be false since the thread local is false')
    end
    
    def test_is_execution_traced_true
      Thread.current[:newrelic_untraced] = [true, true]
      assert_equal(true, NewRelic::Agent.is_execution_traced?, 'should be true since the thread local is set')
    end

    def test_is_execution_traced_blank
      Thread.current[:newrelic_untraced] = nil
      assert_equal(true, NewRelic::Agent.is_execution_traced?, 'should be true since the thread local is not set')
    end

    def test_is_execution_traced_empty
      Thread.current[:newrelic_untraced] = []
      assert_equal(true, NewRelic::Agent.is_execution_traced?, 'should be true since the thread local is an empty array')
    end

    def test_is_execution_traced_false
      Thread.current[:newrelic_untraced] = [true, false]
      assert_equal(false, NewRelic::Agent.is_execution_traced?, 'should be false since the thread local stack has the last element false')
    end
    
    def test_instance
      assert_equal(NewRelic::Agent.agent, NewRelic::Agent.instance, "should return the same agent for both identical methods")
    end

    def test_load_data_should_not_write_files_when_serialization_disabled
      NewRelic::Control.instance['disable_serialization'] = true
      NewRelic::DataSerialization.expects(:read_and_write_to_file).never
      NewRelic::Agent.load_data
      NewRelic::Control.instance['disable_serialization'] = false
    end

    private

    def mocked_agent
      agent = mock('agent')
      NewRelic::Agent.stubs(:agent).returns(agent)
      agent
    end

    def mocked_control
      control = mock('control')
      NewRelic::Control.stubs(:instance).returns(control)
      control
    end
  end
end
