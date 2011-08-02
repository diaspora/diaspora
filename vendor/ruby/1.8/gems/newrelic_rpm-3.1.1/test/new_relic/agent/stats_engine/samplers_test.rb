require File.expand_path(File.join(File.dirname(__FILE__),'..', '..','..','test_helper'))
require 'new_relic/agent/samplers/cpu_sampler'

class NewRelic::Agent::StatsEngine::SamplersTest < Test::Unit::TestCase

  class TestObject
    include NewRelic::Agent::StatsEngine::Samplers
  end

  def setup
    @stats_engine = NewRelic::Agent::StatsEngine.new
    NewRelic::Agent.instance.stubs(:stats_engine).returns(@stats_engine)
  end

  def test_add_sampler_to_positive
    object = TestObject.new
    sampler = mock('sampler')
    sampler_array = mock('sampler_array')
    sampler_array.expects(:include?).with(sampler).returns(false)
    sampler_array.expects(:<<).with(sampler)
    sampler.expects(:stats_engine=).with(object)

    object.send(:add_sampler_to, sampler_array, sampler)
  end

  def test_add_sampler_to_negative
    object = TestObject.new
    sampler = mock('sampler')
    sampler_array = mock('sampler_array')
    sampler_array.expects(:include?).with(sampler).returns(true)
    assert_raise(RuntimeError) do
      object.send(:add_sampler_to, sampler_array, sampler)
    end
  end

  def test_cpu
    s = NewRelic::Agent::Samplers::CpuSampler.new
    # need to set this instance value to prevent it skipping a 'too
    # fast' poll time
    s.stats_engine = @stats_engine
    s.instance_eval { @last_time = Time.now - 1.1 }
    s.poll
    s.instance_eval { @last_time = Time.now - 1.1 }
    s.poll
    assert_equal 2, s.systemtime_stats.call_count
    assert_equal 2, s.usertime_stats.call_count
    assert s.usertime_stats.total_call_time >= 0, "user cpu greater/equal to 0: #{s.usertime_stats.total_call_time}"
    assert s.systemtime_stats.total_call_time >= 0, "system cpu greater/equal to 0: #{s.systemtime_stats.total_call_time}"
  end
  def test_memory__default
    s = NewRelic::Agent::Samplers::MemorySampler.new
    s.stats_engine = @stats_engine
    s.poll
    s.poll
    s.poll
    assert_equal 3, s.stats.call_count
    assert s.stats.total_call_time > 0.5, "cpu greater than 0.5 ms: #{s.stats.total_call_time}"
  end
  def test_memory__linux
    return if RUBY_PLATFORM =~ /darwin/
    NewRelic::Agent::Samplers::MemorySampler.any_instance.stubs(:platform).returns 'linux'
    s = NewRelic::Agent::Samplers::MemorySampler.new
    s.stats_engine = @stats_engine
    s.poll
    s.poll
    s.poll
    assert_equal 3, s.stats.call_count
    assert s.stats.total_call_time > 0.5, "cpu greater than 0.5 ms: #{s.stats.total_call_time}"
  end
  def test_memory__solaris
    return if defined? JRuby
    NewRelic::Agent::Samplers::MemorySampler.any_instance.stubs(:platform).returns 'solaris'
    NewRelic::Agent::Samplers::MemorySampler::ShellPS.any_instance.stubs(:get_memory).returns 999
    s = NewRelic::Agent::Samplers::MemorySampler.new
    s.stats_engine = @stats_engine
    s.poll
    assert_equal 1, s.stats.call_count
    assert_equal 999, s.stats.total_call_time
  end
  def test_memory__windows
    return if defined? JRuby
    NewRelic::Agent::Samplers::MemorySampler.any_instance.stubs(:platform).returns 'win32'
    assert_raise NewRelic::Agent::Sampler::Unsupported do
      NewRelic::Agent::Samplers::MemorySampler.new
    end
  end
  def test_load_samplers
    @stats_engine.expects(:add_harvest_sampler).at_least_once unless defined? JRuby
    @stats_engine.expects(:add_sampler).never
    NewRelic::Control.instance.load_samplers
    sampler_count = 4
    assert_equal sampler_count, NewRelic::Agent::Sampler.sampler_classes.size, NewRelic::Agent::Sampler.sampler_classes.inspect
  end
  def test_memory__is_supported
    NewRelic::Agent::Samplers::MemorySampler.stubs(:platform).returns 'windows'
    assert !NewRelic::Agent::Samplers::MemorySampler.supported_on_this_platform? || defined? JRuby
  end

end
