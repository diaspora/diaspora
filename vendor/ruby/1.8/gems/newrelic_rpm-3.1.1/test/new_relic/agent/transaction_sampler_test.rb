require File.expand_path(File.join(File.dirname(__FILE__),'..','..','test_helper'))

class NewRelic::Agent::TransactionSamplerTest < Test::Unit::TestCase

  module MockGCStats

    def time
      return 0 if @@values.empty?
      raise "too many calls" if @@index >= @@values.size
      @@curtime ||= 0
      @@curtime += (@@values[@@index] * 1e09).to_i
      @@index += 1
      @@curtime
    end

    def self.mock_values= array
      @@values = array
      @@index = 0
    end

  end

  def setup
    Thread::current[:record_sql] = nil
    agent = NewRelic::Agent.instance
    stats_engine = NewRelic::Agent::StatsEngine.new
    agent.stubs(:stats_engine).returns(stats_engine)
    @sampler = NewRelic::Agent::TransactionSampler.new
    stats_engine.transaction_sampler = @sampler
  end

  def teardown
    super
    Thread.current[:transaction_sample_builder] = nil
  end

  def test_initialize
    defaults =      {
      :samples => [],
      :harvest_count => 0,
      :max_samples => 100,
      :random_sample => nil,
    }
    defaults.each do |variable, default_value|
      assert_equal(default_value, @sampler.instance_variable_get('@' + variable.to_s))
    end

    segment_limit = @sampler.instance_variable_get('@segment_limit')
    assert(segment_limit.is_a?(Numeric), "Segment limit should be numeric")
    assert(segment_limit > 0, "Segment limit should be above zero")

    stack_trace_threshold = @sampler.instance_variable_get('@stack_trace_threshold')
    assert(stack_trace_threshold.is_a?((0.1).class), "Stack trace threshold should be a #{(0.1).class.inspect}, but is #{stack_trace_threshold.inspect}")
    assert(stack_trace_threshold > 0.0, "Stack trace threshold should be above zero")

    lock = @sampler.instance_variable_get('@samples_lock')
    assert(lock.is_a?(Mutex), "Samples lock should be a mutex, is: #{lock.inspect}")
  end

  def test_current_sample_id_default
    builder = mock('builder')
    builder.expects(:sample_id).returns(11111)
    @sampler.expects(:builder).returns(builder)
    assert_equal(11111, @sampler.current_sample_id)
  end

  def test_current_sample_id_no_builder
    @sampler.expects(:builder).returns(nil)
    assert_equal(nil, @sampler.current_sample_id)
  end

  def test_enable
    assert_equal(nil, @sampler.instance_variable_get('@disabled'))
    @sampler.enable
    assert_equal(false, @sampler.instance_variable_get('@disabled'))
    assert_equal(@sampler, NewRelic::Agent.instance.stats_engine.instance_variable_get('@transaction_sampler'))
  end

  def test_disable
    assert_equal(nil, @sampler.instance_variable_get('@disabled'))
    @sampler.disable
    assert_equal(true, @sampler.instance_variable_get('@disabled'))
    assert_equal(nil, NewRelic::Agent.instance.stats_engine.instance_variable_get('@transaction_sampler'))
  end

  def test_sampling_rate_equals_default
    @sampler.sampling_rate = 1
    assert_equal(1, @sampler.instance_variable_get('@sampling_rate'))
    # rand(1) is always zero, so we can be sure here
    assert_equal(0, @sampler.instance_variable_get('@harvest_count'))
  end

  def test_sampling_rate_equals_with_a_float
    @sampler.sampling_rate = 5.5
    assert_equal(5, @sampler.instance_variable_get('@sampling_rate'))
    harvest_count = @sampler.instance_variable_get('@harvest_count')
    assert((0..4).include?(harvest_count), "should be in the range 0..4")
  end

  def test_notice_first_scope_push_default
    @sampler.expects(:disabled).returns(false)
    @sampler.expects(:start_builder).with(100.0)
    @sampler.notice_first_scope_push(Time.at(100))
  end

  def test_notice_first_scope_push_disabled
    @sampler.expects(:disabled).returns(true)
    @sampler.expects(:start_builder).never
    @sampler.notice_first_scope_push(Time.at(100))
  end

  def test_notice_push_scope_no_builder
    @sampler.expects(:builder)
    assert_equal(nil, @sampler.notice_push_scope('a scope'))
  end

  def test_notice_push_scope_with_builder
    NewRelic::Control.instance.expects(:developer_mode?).returns(false)
    builder = mock('builder')
    builder.expects(:trace_entry).with('a scope', 100.0)
    @sampler.expects(:builder).returns(builder).twice

    @sampler.notice_push_scope('a scope', Time.at(100))
  end

  def test_notice_push_scope_in_dev_mode
    NewRelic::Control.instance.expects(:developer_mode?).returns(true)

    builder = mock('builder')
    builder.expects(:trace_entry).with('a scope', 100.0)
    @sampler.expects(:builder).returns(builder).twice
    @sampler.expects(:capture_segment_trace)

    @sampler.notice_push_scope('a scope', Time.at(100))
  end

  def test_scope_depth_no_builder
    @sampler.expects(:builder).returns(nil)
    assert_equal(0, @sampler.scope_depth, "should default to zero with no builder")
  end

  def test_scope_depth_with_builder
    builder = mock('builder')
    builder.expects(:scope_depth).returns('scope_depth')
    @sampler.expects(:builder).returns(builder).twice

    assert_equal('scope_depth', @sampler.scope_depth, "should delegate scope depth to the builder")
  end

  def test_notice_pop_scope_no_builder
    @sampler.expects(:builder).returns(nil)
    assert_equal(nil, @sampler.notice_pop_scope('a scope', Time.at(100)))
  end

  def test_notice_pop_scope_with_frozen_sample
    builder = mock('builder')
    sample = mock('sample')
    builder.expects(:sample).returns(sample)
    sample.expects(:frozen?).returns(true)
    @sampler.expects(:builder).returns(builder).twice

    assert_raise(RuntimeError) do
      @sampler.notice_pop_scope('a scope', Time.at(100))
    end
  end

  def test_notice_pop_scope_builder_delegation
    builder = mock('builder')
    builder.expects(:trace_exit).with('a scope', 100.0)
    sample = mock('sample')
    builder.expects(:sample).returns(sample)
    sample.expects(:frozen?).returns(false)
    @sampler.expects(:builder).returns(builder).times(3)

    @sampler.notice_pop_scope('a scope', Time.at(100))
  end

  def test_notice_scope_empty_no_builder
    @sampler.expects(:builder).returns(nil)
    assert_equal(nil, @sampler.notice_scope_empty)
  end

  def test_notice_scope_empty_ignored_transaction
    builder = mock('builder')
    # the builder should be cached, so only called once
    @sampler.expects(:builder).returns(builder).once

    builder.expects(:finish_trace).with(100.0)

    @sampler.expects(:clear_builder)

    builder.expects(:ignored?).returns(true)

    assert_equal(nil, @sampler.notice_scope_empty(Time.at(100)))
  end

  def test_notice_scope_empty_with_builder
    builder = mock('builder')
    # the builder should be cached, so only called once
    @sampler.expects(:builder).returns(builder).once


    builder.expects(:finish_trace).with(100.0)
    @sampler.expects(:clear_builder)

    builder.expects(:ignored?).returns(false)

    sample = mock('sample')
    builder.expects(:sample).returns(sample)
    @sampler.expects(:store_sample).with(sample)

    @sampler.notice_scope_empty(Time.at(100))

    assert_equal(sample, @sampler.instance_variable_get('@last_sample'))
  end

  def test_store_random_sample_no_random_sampling
    @sampler.instance_eval { @random_sampling = false }
    assert_equal(nil, @sampler.instance_variable_get('@random_sample'))
    @sampler.store_random_sample(mock('sample'))
    assert_equal(nil, @sampler.instance_variable_get('@random_sample'))
  end

  def test_store_random_sample_random_sampling
    @sampler.instance_eval { @random_sampling = true }
    sample = mock('sample')
    assert_equal(nil, @sampler.instance_variable_get('@random_sample'))
    @sampler.store_random_sample(sample)
    assert_equal(sample, @sampler.instance_variable_get('@random_sample'))
  end

  def test_store_sample_for_developer_mode_in_dev_mode
    NewRelic::Control.instance.expects(:developer_mode?).returns(true)
    sample = mock('sample')
    @sampler.expects(:truncate_samples)
    @sampler.store_sample_for_developer_mode(sample)
    assert_equal([sample], @sampler.instance_variable_get('@samples'))
  end

  def test_store_sample_for_developer_mode_no_dev
    NewRelic::Control.instance.expects(:developer_mode?).returns(false)
    sample = mock('sample')
    @sampler.store_sample_for_developer_mode(sample)
    assert_equal([], @sampler.instance_variable_get('@samples'))
  end

  def test_store_slowest_sample_new_is_slowest
    old_sample = mock('old_sample')
    new_sample = mock('new_sample')
    @sampler.instance_eval { @slowest_sample = old_sample }
    @sampler.expects(:slowest_sample?).with(old_sample, new_sample).returns(true)

    @sampler.store_slowest_sample(new_sample)

    assert_equal(new_sample, @sampler.instance_variable_get('@slowest_sample'))
  end


  def test_store_slowest_sample_not_slowest
    old_sample = mock('old_sample')
    new_sample = mock('new_sample')
    @sampler.instance_eval { @slowest_sample = old_sample }
    @sampler.expects(:slowest_sample?).with(old_sample, new_sample).returns(false)

    @sampler.store_slowest_sample(new_sample)

    assert_equal(old_sample, @sampler.instance_variable_get('@slowest_sample'))
  end

  def test_slowest_sample_no_sample
    old_sample = nil
    new_sample = mock('new_sample')
    assert_equal(true, @sampler.slowest_sample?(old_sample, new_sample))
  end

  def test_slowest_sample_faster_sample
    old_sample = mock('old_sample')
    new_sample = mock('new_sample')
    old_sample.expects(:duration).returns(1.0)
    new_sample.expects(:duration).returns(0.5)
    assert_equal(false, @sampler.slowest_sample?(old_sample, new_sample))
  end

  def test_slowest_sample_slower_sample
    old_sample = mock('old_sample')
    new_sample = mock('new_sample')
    old_sample.expects(:duration).returns(0.5)
    new_sample.expects(:duration).returns(1.0)
    assert_equal(true, @sampler.slowest_sample?(old_sample, new_sample))
  end

  def test_truncate_samples_no_samples
    @sampler.instance_eval { @max_samples = 10 }
    @sampler.instance_eval { @samples = [] }
    @sampler.truncate_samples
    assert_equal([], @sampler.instance_variable_get('@samples'))
  end

  def test_truncate_samples_equal_samples
    @sampler.instance_eval { @max_samples = 2 }
    @sampler.instance_eval { @samples = [1, 2] }
    @sampler.truncate_samples
    assert_equal([1, 2], @sampler.instance_variable_get('@samples'))
  end

  def test_truncate_samples_extra_samples
    @sampler.instance_eval { @max_samples = 2 }
    @sampler.instance_eval { @samples = [1, 2, 3] }
    @sampler.truncate_samples
    assert_equal([2, 3], @sampler.instance_variable_get('@samples'))
  end

  def test_notice_transaction_disabled
    @sampler.expects(:disabled).returns(true)
    @sampler.expects(:builder).never # since we're disabled
    @sampler.notice_transaction('foo')
  end

  def test_notice_transaction_no_builder
    @sampler.expects(:disabled).returns(false)
    @sampler.expects(:builder).returns(nil).once
    @sampler.notice_transaction('foo')
  end

  def test_notice_transaction_with_builder
    builder = mock('builder')
    builder.expects(:set_transaction_info).with('a path', 'a uri', {:some => :params})
    @sampler.expects(:builder).returns(builder).twice
    @sampler.expects(:disabled).returns(false)
    @sampler.notice_transaction('a path', 'a uri', {:some => :params})
  end

  def test_ignore_transaction_no_builder
    @sampler.expects(:builder).returns(nil).once
    @sampler.ignore_transaction
  end

  def test_ignore_transaction_with_builder
    builder = mock('builder')
    builder.expects(:ignore_transaction)
    @sampler.expects(:builder).returns(builder).twice
    @sampler.ignore_transaction
  end

  def test_notice_profile_no_builder
    @sampler.expects(:builder).returns(nil).once
    @sampler.notice_profile(nil)
  end

  def test_notice_profile_with_builder
    profile = mock('profile')
    builder = mock('builder')
    @sampler.expects(:builder).returns(builder).twice
    builder.expects(:set_profile).with(profile)

    @sampler.notice_profile(profile)
  end

  def test_notice_transaction_cpu_time_no_builder
    @sampler.expects(:builder).returns(nil).once
    @sampler.notice_transaction_cpu_time(0.0)
  end

  def test_notice_transaction_cpu_time_with_builder
    cpu_time = mock('cpu_time')
    builder = mock('builder')
    @sampler.expects(:builder).returns(builder).twice
    builder.expects(:set_transaction_cpu_time).with(cpu_time)

    @sampler.notice_transaction_cpu_time(cpu_time)
  end

  def test_notice_extra_data_no_builder
    @sampler.expects(:builder).returns(nil).once
    @sampler.send(:notice_extra_data, nil, nil, nil)
  end

  def test_notice_extra_data_no_segment
    builder = mock('builder')
    @sampler.expects(:builder).returns(builder).twice
    builder.expects(:current_segment).returns(nil)
    @sampler.send(:notice_extra_data, nil, nil, nil)
  end

  def test_notice_extra_data_with_segment_no_old_message_no_config_key
    key = :a_key
    builder = mock('builder')
    segment = mock('segment')
    @sampler.expects(:builder).returns(builder).twice
    builder.expects(:current_segment).returns(segment)
    segment.expects(:[]).with(key).returns(nil)
    @sampler.expects(:append_new_message).with(nil, 'a message').returns('a message')
    @sampler.expects(:truncate_message).with('a message').returns('truncated_message')
    segment.expects(:[]=).with(key, 'truncated_message')
    @sampler.expects(:append_backtrace).with(segment, 1.0)
    @sampler.send(:notice_extra_data, 'a message', 1.0, key)
  end

  def test_truncate_message_short_message
    message = 'a message'
    assert_equal(message, @sampler.truncate_message(message))
  end

  def test_truncate_message_long_message
    message = 'a' * 16384
    truncated_message = @sampler.truncate_message(message)
    assert_equal(16384, truncated_message.length)
    assert_equal('a' * 16381 + '...', truncated_message)
  end

  def test_append_new_message_no_old_message
    old_message = nil
    new_message = 'a message'
    assert_equal(new_message, @sampler.append_new_message(old_message, new_message))
  end

  def test_append_new_message_with_old_message
    old_message = 'old message'
    new_message = ' a message'
    assert_equal("old message;\n a message", @sampler.append_new_message(old_message, new_message))
  end

  def test_append_backtrace_under_duration
    @sampler.instance_eval { @stack_trace_threshold = 2.0 }
    segment = mock('segment')
    segment.expects(:[]=).with(:backtrace, any_parameters).never
    @sampler.append_backtrace(mock('segment'), 1.0)
  end

  def test_append_backtrace_over_duration
    @sampler.instance_eval { @stack_trace_threshold = 2.0 }
    segment = mock('segment')
    # note the mocha expectation matcher - you can't hardcode a
    # backtrace so we match on any string, which should be okay.
    segment.expects(:[]=).with(:backtrace, instance_of(String))
    @sampler.append_backtrace(segment, 2.5)
  end

  def test_notice_sql_recording_sql
    Thread.current[:record_sql] = true
    @sampler.expects(:notice_extra_data).with('some sql', 1.0, :sql, 'a config', :connection_config)
    @sampler.notice_sql('some sql', 'a config', 1.0)
  end

  def test_notice_sql_not_recording
    Thread.current[:record_sql] = false
    @sampler.expects(:notice_extra_data).with('some sql', 1.0, :sql, 'a config', :connection_config).never # <--- important
    @sampler.notice_sql('some sql', 'a config', 1.0)
  end

  def test_notice_nosql
    @sampler.expects(:notice_extra_data).with('a key', 1.0, :key)
    @sampler.notice_nosql('a key', 1.0)
  end

  def test_harvest_when_disabled
    @sampler.expects(:disabled).returns(true)
    assert_equal([], @sampler.harvest)
  end

  def test_harvest_defaults
    # making sure the sampler clears out the old samples
    @sampler.instance_eval do
      @slowest_sample = 'a sample'
      @random_sample = 'a sample'
      @last_sample = 'a sample'
    end

    @sampler.expects(:disabled).returns(false)
    @sampler.expects(:add_samples_to).with([], 2.0).returns([])

    assert_equal([], @sampler.harvest)

    # make sure the samples have been cleared
    assert_equal(nil, @sampler.instance_variable_get('@slowest_sample'))
    assert_equal(nil, @sampler.instance_variable_get('@random_sample'))
    assert_equal(nil, @sampler.instance_variable_get('@last_sample'))
  end

  def test_harvest_with_previous_samples
    sample = mock('sample')
    @sampler.expects(:disabled).returns(false)
    @sampler.expects(:add_samples_to).with([sample], 2.0).returns([sample])
    @sampler.instance_eval { @segment_limit = 2000 }
    sample.expects(:truncate).with(2000)
    assert_equal([sample], @sampler.harvest([sample]))
  end

  def test_add_random_sample_to_not_random_sampling
    @sampler.instance_eval { @random_sampling = false }
    result = []
    @sampler.add_random_sample_to(result)
    assert_equal([], result, "should not add anything to the array if we are not random sampling")
  end

  def test_add_random_sample_to_no_random_sample
    @sampler.instance_eval { @random_sampling = true }
    @sampler.instance_eval {
      @harvest_count = 1
      @sampling_rate = 2
      @random_sample = nil
    }
    result = []
    @sampler.add_random_sample_to(result)
    assert_equal([], result, "should not add sample to the array when it is nil")
  end

  def test_add_random_sample_to_not_active
    @sampler.instance_eval { @random_sampling = true }
    sample = mock('sample')
    @sampler.instance_eval {
      @harvest_count = 4
      @sampling_rate = 40 # 4 % 40 = 4, so the sample should not be added
      @random_sample = sample
    }
    result = []
    @sampler.add_random_sample_to(result)
    assert_equal([], result, "should not add samples to the array when harvest count is not moduli sampling rate")
  end

  def test_add_random_sample_to_duplicate
    @sampler.instance_eval { @random_sampling = true }
    sample = mock('sample')
    @sampler.instance_eval {
      @harvest_count = 1
      @sampling_rate = 2
      @random_sample = sample
    }
    result = [sample]
    @sampler.add_random_sample_to(result)
    assert_equal([sample], result, "should not add duplicate samples to the array")
  end

  def test_add_random_sample_to_activated
    @sampler.instance_eval { @random_sampling = true }
    sample = mock('sample')
    @sampler.instance_eval {
      @harvest_count = 3
      @sampling_rate = 1
      @random_sample = sample
    }
    result = []
    @sampler.add_random_sample_to(result)
    assert_equal([sample], result, "should add the random sample to the array")
  end

  def test_add_random_sample_to_sampling_rate_zero
    @sampler.instance_eval { @random_sampling = true }
    sample = mock('sample')
    @sampler.instance_eval {
      @harvest_count = 3
      @sampling_rate = 0
      @random_sample = sample
    }
    result = []
    @sampler.add_random_sample_to(result)
    assert_equal([], result, "should not add the sample to the array")
  end


  def test_add_samples_to_no_data
    result = []
    slow_threshold = 2.0
    @sampler.instance_eval { @slowest_sample = nil }
    @sampler.expects(:add_random_sample_to).with([])
    assert_equal([], @sampler.add_samples_to(result, slow_threshold))
  end

  def test_add_samples_to_one_result
    sample = mock('sample')
    sample.expects(:duration).returns(1).at_least_once
    result = [sample]
    slow_threshold = 2.0
    @sampler.instance_eval { @slowest_sample = nil }
    @sampler.expects(:add_random_sample_to).with([sample])
    assert_equal([sample], @sampler.add_samples_to(result, slow_threshold))
  end

  def test_add_samples_to_adding_slowest
    sample = mock('sample')
    sample.expects(:duration).returns(2.5).at_least_once
    result = []
    slow_threshold = 2.0
    @sampler.instance_eval { @slowest_sample = sample }
    @sampler.expects(:add_random_sample_to).with([sample])
    assert_equal([sample], @sampler.add_samples_to(result, slow_threshold))
  end

  def test_add_samples_to_under_threshold
    result = []
    slow_threshold = 2.0
    sample = mock('sample')
    sample.expects(:duration).returns(1.0).at_least_once
    @sampler.instance_eval { @slowest_sample = sample }
    @sampler.expects(:add_random_sample_to).with([])
    assert_equal([], @sampler.add_samples_to(result, slow_threshold))
  end

  def test_add_samples_to_two_sample_enter_one_sample_leave
    slower_sample = mock('slower')
    slower_sample.expects(:duration).returns(10.0).at_least_once
    faster_sample = mock('faster')
    faster_sample.expects(:duration).returns(5.0).at_least_once
    result = [faster_sample]
    slow_threshold = 2.0
    @sampler.instance_eval { @slowest_sample = slower_sample }
    @sampler.expects(:add_random_sample_to).with([slower_sample])
    assert_equal([slower_sample], @sampler.add_samples_to(result, slow_threshold))
  end

  def test_add_samples_to_keep_older_slower_sample
    slower_sample = mock('slower')
    slower_sample.expects(:duration).returns(10.0).at_least_once
    faster_sample = mock('faster')
    faster_sample.expects(:duration).returns(5.0).at_least_once
    result = [slower_sample]
    slow_threshold = 2.0
    @sampler.instance_eval { @slowest_sample = faster_sample }
    @sampler.expects(:add_random_sample_to).with([slower_sample])
    assert_equal([slower_sample], @sampler.add_samples_to(result, slow_threshold))
  end

  def test_start_builder_default
    Thread.current[:record_tt] = true
    @sampler.expects(:disabled).returns(false)
    NewRelic::Agent.expects(:is_execution_traced?).returns(true)
    @sampler.send(:start_builder)
    assert(Thread.current[:transaction_sample_builder].is_a?(NewRelic::Agent::TransactionSampleBuilder), "should set up a new builder by default")
  end

  def test_start_builder_disabled
    Thread.current[:transaction_sample_builder] = 'not nil.'
    @sampler.expects(:disabled).returns(true)
    @sampler.send(:start_builder)
    assert_equal(nil, Thread.current[:transaction_sample_builder], "should clear the transaction builder when disabled")
  end

  def test_start_builder_dont_replace_existing_builder
    fake_builder = mock('transaction sample builder')
    Thread.current[:transaction_sample_builder] = fake_builder
    @sampler.expects(:disabled).returns(false)
    @sampler.send(:start_builder)
    assert_equal(fake_builder, Thread.current[:transaction_sample_builder], "should not overwrite an existing transaction sample builder")
  end

  def test_builder
    Thread.current[:transaction_sample_builder] = 'shamalamadingdong, brother.'
    assert_equal('shamalamadingdong, brother.', @sampler.send(:builder), 'should return the value from the thread local variable')
    Thread.current[:transaction_sample_builder] = nil
  end

  def test_clear_builder
    Thread.current[:transaction_sample_builder] = 'shamalamadingdong, brother.'
    assert_equal(nil, @sampler.send(:clear_builder), 'should clear the thread local variable')
  end

  # Tests below this line are functional tests for the sampler, not
  # unit tests per se - some overlap with the tests above, but
  # generally usefully so

  def test_multiple_samples

    run_sample_trace
    run_sample_trace
    run_sample_trace
    run_sample_trace

    samples = @sampler.samples
    assert_equal 4, samples.length
    assert_equal "a", samples.first.root_segment.called_segments[0].metric_name
    assert_equal "a", samples.last.root_segment.called_segments[0].metric_name
  end

  def test_sample_tree
    assert_equal 0, @sampler.scope_depth

    @sampler.notice_first_scope_push Time.now.to_f
    @sampler.notice_transaction "/path", nil, {}
    @sampler.notice_push_scope "a"

    @sampler.notice_push_scope "b"
    @sampler.notice_pop_scope "b"

    @sampler.notice_push_scope "c"
    @sampler.notice_push_scope "d"
    @sampler.notice_pop_scope "d"
    @sampler.notice_pop_scope "c"

    @sampler.notice_pop_scope "a"
    @sampler.notice_scope_empty
    sample = @sampler.harvest([],0.0).first
    assert_equal "ROOT{a{b,c{d}}}", sample.to_s_compact

  end

  def test_sample__gc_stats
    GC.extend MockGCStats
    # These are effectively Garbage Collects, detected each time GC.time is
    # called by the transaction sampler.  One time value in seconds for each call.
    MockGCStats.mock_values = [0,0,0,1,0,0,1,0,0,0,0,0,0,0,0]
    assert_equal 0, @sampler.scope_depth

    @sampler.notice_first_scope_push Time.now.to_f
    @sampler.notice_transaction "/path", nil, {}
    @sampler.notice_push_scope "a"

    @sampler.notice_push_scope "b"
    @sampler.notice_pop_scope "b"

    @sampler.notice_push_scope "c"
    @sampler.notice_push_scope "d"
    @sampler.notice_pop_scope "d"
    @sampler.notice_pop_scope "c"

    @sampler.notice_pop_scope "a"
    @sampler.notice_scope_empty

    sample = @sampler.harvest([],0.0).first
    assert_equal "ROOT{a{b,c{d}}}", sample.to_s_compact
  ensure
    MockGCStats.mock_values = []
  end

  def test_sample_id
    run_sample_trace do
      assert((@sampler.current_sample_id && @sampler.current_sample_id != 0), @sampler.current_sample_id.to_s + ' should not be zero')
    end
  end


  # NB this test occasionally fails due to a GC during one of the
  # sample traces, for example. It's unfortunate, but we can't
  # reliably turn off GC on all versions of ruby under test
  def test_harvest_slowest

    run_sample_trace
    run_sample_trace
    run_sample_trace { sleep 0.1 }
    run_sample_trace
    run_sample_trace

    slowest = @sampler.harvest(nil, 0)[0]
    assert((slowest.duration >= 0.09), "expected sample duration >= 0.09, but was: #{slowest.duration.inspect}")
    # this assert is here to make sure the test remains valid
    assert((slowest.duration <= 0.15), "expected sample duration <= 0.15, but was: #{slowest.duration.inspect}")


    run_sample_trace { sleep 0.0001 }
    not_as_slow = @sampler.harvest(slowest, 0)[0]
    assert((not_as_slow == slowest), "Should re-harvest the same transaction since it should be slower than the new transaction - expected #{slowest.inspect} but got #{not_as_slow.inspect}")

    run_sample_trace { sleep 0.16 }
    new_slowest = @sampler.harvest(slowest, 0)[0]
    assert((new_slowest != slowest), "Should not harvest the same trace since the new one should be slower")
    assert((new_slowest.duration >= 0.15), "Slowest duration must be >= 0.15, but was: #{new_slowest.duration.inspect}")
  end


  def test_prepare_to_send

    run_sample_trace { sleep 0.002 }
    sample = @sampler.harvest(nil, 0)[0]

    ready_to_send = sample.prepare_to_send
    assert sample.duration == ready_to_send.duration

    assert ready_to_send.start_time.is_a?(Time)
  end

  def test_multithread
    threads = []

    5.times do
      t = Thread.new(@sampler) do |the_sampler|
        @sampler = the_sampler
        10.times do
          run_sample_trace { sleep 0.0001 }
        end
      end

      threads << t
    end
    threads.each {|t| t.join }
  end

  def test_sample_with_parallel_paths

    assert_equal 0, @sampler.scope_depth

    @sampler.notice_first_scope_push Time.now.to_f
    @sampler.notice_transaction "/path", nil, {}
    @sampler.notice_push_scope "a"

    assert_equal 1, @sampler.scope_depth

    @sampler.notice_pop_scope "a"
    @sampler.notice_scope_empty

    assert_equal 0, @sampler.scope_depth

    @sampler.notice_first_scope_push Time.now.to_f
    @sampler.notice_transaction "/path", nil, {}
    @sampler.notice_push_scope "a"
    @sampler.notice_pop_scope "a"
    @sampler.notice_scope_empty

    assert_equal 0, @sampler.scope_depth
    sample = @sampler.harvest(nil, 0.0).first
    assert_equal "ROOT{a}", sample.to_s_compact
  end

  def test_double_scope_stack_empty

    @sampler.notice_first_scope_push Time.now.to_f
    @sampler.notice_transaction "/path", nil, {}
    @sampler.notice_push_scope "a"
    @sampler.notice_pop_scope "a"
    @sampler.notice_scope_empty
    @sampler.notice_scope_empty
    @sampler.notice_scope_empty
    @sampler.notice_scope_empty

    assert_not_nil @sampler.harvest(nil, 0)[0]
  end


  def test_record_sql_off

    @sampler.notice_first_scope_push Time.now.to_f

    Thread::current[:record_sql] = false

    @sampler.notice_sql("test", nil, 0)

    segment = @sampler.send(:builder).current_segment

    assert_nil segment[:sql]
  end

  def test_stack_trace__sql
    @sampler.stack_trace_threshold = 0

    @sampler.notice_first_scope_push Time.now.to_f

    @sampler.notice_sql("test", nil, 1)

    segment = @sampler.send(:builder).current_segment

    assert segment[:sql]
    assert segment[:backtrace]
  end
  def test_stack_trace__scope

    @sampler.stack_trace_threshold = 0
    t = Time.now
    @sampler.notice_first_scope_push t.to_f
    @sampler.notice_push_scope 'Bill', (t+1).to_f

    segment = @sampler.send(:builder).current_segment
    assert segment[:backtrace]
  end

  def test_nil_stacktrace

    @sampler.stack_trace_threshold = 2

    @sampler.notice_first_scope_push Time.now.to_f

    @sampler.notice_sql("test", nil, 1)

    segment = @sampler.send(:builder).current_segment

    assert segment[:sql]
    assert_nil segment[:backtrace]
  end

  def test_big_sql

    @sampler.notice_first_scope_push Time.now.to_f

    sql = "SADJKHASDHASD KAJSDH ASKDH ASKDHASDK JASHD KASJDH ASKDJHSAKDJHAS DKJHSADKJSAH DKJASHD SAKJDH SAKDJHS"

    len = 0
    while len <= 16384
      @sampler.notice_sql(sql, nil, 0)
      len += sql.length
    end

    segment = @sampler.send(:builder).current_segment

    sql = segment[:sql]

    assert sql.length <= 16384
  end


  def test_segment_obfuscated

    @sampler.notice_first_scope_push Time.now.to_f
    @sampler.notice_push_scope "foo"

    orig_sql = "SELECT * from Jim where id=66"

    @sampler.notice_sql(orig_sql, nil, 0)

    segment = @sampler.send(:builder).current_segment

    assert_equal orig_sql, segment[:sql]
    assert_equal "SELECT * from Jim where id=?", segment.obfuscated_sql
    @sampler.notice_pop_scope "foo"
  end


  def test_param_capture
    [true, false].each do |capture|
      NewRelic::Control.instance.stubs(:capture_params).returns(capture)
      @sampler.notice_first_scope_push Time.now.to_f
      @sampler.notice_transaction('/path', nil, {:param => 'hi'})
      @sampler.notice_scope_empty

      tt = @sampler.harvest(nil,0)[0]

      assert_equal (capture) ? 1 : 0, tt.params[:request_params].length
    end
  end


  private
  def run_sample_trace(&proc)
    @sampler.notice_first_scope_push Time.now.to_f
    @sampler.notice_transaction '/path', nil, {}
    @sampler.notice_push_scope "a"
    @sampler.notice_sql("SELECT * FROM sandwiches WHERE bread = 'wheat'", nil, 0)
    @sampler.notice_push_scope "ab"
    @sampler.notice_sql("SELECT * FROM sandwiches WHERE bread = 'white'", nil, 0)
    proc.call if proc
    @sampler.notice_pop_scope "ab"
    @sampler.notice_push_scope "lew"
    @sampler.notice_sql("SELECT * FROM sandwiches WHERE bread = 'french'", nil, 0)
    @sampler.notice_pop_scope "lew"
    @sampler.notice_pop_scope "a"
    @sampler.notice_scope_empty
  end

end
