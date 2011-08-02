require File.expand_path(File.join(File.dirname(__FILE__),'..','..','..','..','test_helper'))
require 'new_relic/agent/stats_engine/metric_stats'
class NewRelic::Agent::StatsEngine::MetricStats::HarvestTest < Test::Unit::TestCase
  include NewRelic::Agent::StatsEngine::MetricStats::Harvest

  attr_accessor :stats_hash
  def test_merge_stats_trivial
    self.stats_hash = {}
    merge_stats({}, {})
  end

  def test_merge_stats_with_nil_stats
    metric_ids = mock('metric ids')
    mock_stats_hash = mock('stats_hash')
    mock_spec = mock('spec')
    mock_stats = mock('stats')
    mock_stats_hash.expects(:each).yields(mock_spec, mock_stats)
    self.stats_hash = mock_stats_hash

    self.expects(:coerce_to_metric_spec).with(mock_spec).returns(mock_spec)
    self.expects(:clone_and_reset_stats).with(mock_spec, mock_stats).returns(mock_stats)
    self.expects(:merge_old_data!).with(mock_spec, mock_stats, {})
    metric_ids.expects(:[]).with(mock_spec).returns('an id')
    self.expects(:add_data_to_send_unless_empty).with({}, mock_stats, mock_spec, 'an id')


    merge_stats({}, metric_ids)
  end


  def test_get_stats_hash_from_hash
    assert_equal({}, get_stats_hash_from({}))
  end

  def test_get_stats_hash_from_engine
    assert_equal({}, get_stats_hash_from(NewRelic::Agent::StatsEngine.new))
  end

  def test_coerce_to_metric_spec_metric_spec
    assert_equal NewRelic::MetricSpec.new, coerce_to_metric_spec(NewRelic::MetricSpec.new)
  end

  def test_coerce_to_metric_spec_string
    assert_equal NewRelic::MetricSpec.new('foo'), coerce_to_metric_spec('foo')
  end

  def test_clone_and_reset_stats_nil
    spec = NewRelic::MetricSpec.new('foo', 'bar')
    stats = nil
    begin
      clone_and_reset_stats(spec, stats)
    rescue RuntimeError => e
      assert_equal("Nil stats for foo (bar)", e.message)
    end
  end

  def test_clone_and_reset_stats_present
    # spec is only used for debug output
    spec = nil
    stats = mock('stats')
    stats_clone = mock('stats_clone')
    stats.expects(:clone).returns(stats_clone)
    stats.expects(:reset)
    # should return a clone
    assert_equal stats_clone, clone_and_reset_stats(spec, stats)
  end

  def test_merge_old_data_present
    metric_spec = mock('metric_spec')
    stats = mock('stats obj')
    stats.expects(:merge!).with('some stats')
    old_data = mock('old data')
    old_data.expects(:stats).returns('some stats')
    old_data_hash = {metric_spec => old_data}
    merge_old_data!(metric_spec, stats, old_data_hash)
  end

  def test_merge_old_data_nil
    metric_spec = mock('metric_spec')
    stats = mock('stats') # doesn't matter
    old_data_hash = {metric_spec => nil}
    merge_old_data!(metric_spec, stats, old_data_hash)
  end

  def test_add_data_to_send_unless_empty_when_is_empty
    stats = mock('stats')
    stats.expects(:is_reset?).returns(true)
    assert_equal nil, add_data_to_send_unless_empty(nil, stats, nil, nil)
  end

  def test_add_data_to_send_unless_empty_main
    data = mock('data hash')
    stats = mock('stats')
    stats.expects(:is_reset?).returns(false)
    metric_spec = mock('spec')

    NewRelic::MetricData.expects(:new).with(metric_spec, stats, nil).returns('metric data')
    data.expects(:[]=).with(metric_spec, 'metric data')
    add_data_to_send_unless_empty(data, stats, metric_spec, nil)
  end

  def test_add_data_to_send_unless_empty_with_id
    data = mock('data hash')
    stats = mock('stats')
    stats.expects(:is_reset?).returns(false)
    metric_spec = mock('spec')
    id = mock('id')

    NewRelic::MetricData.expects(:new).with(nil, stats, id).returns('metric data')
    data.expects(:[]=).with(metric_spec, 'metric data')
    assert_equal 'metric data', add_data_to_send_unless_empty(data, stats, metric_spec, id)
  end

  def test_merge_data_basic
    mock_stats_hash = mock('stats hash')
    self.stats_hash = mock_stats_hash
    merge_data({})
  end

  def test_merge_data_new_and_old_data
    stats = NewRelic::MethodTraceStats.new
    stats.record_data_point(1.0)
    new_stats = NewRelic::MethodTraceStats.new
    new_stats.record_data_point(2.0)
    self.expects(:lookup_stats).with('Custom/test/method', '').returns(new_stats)
    assert_equal(2.0, new_stats.total_call_time)

    metric_spec = NewRelic::MetricSpec.new('Custom/test/method')
    mock_stats_hash = mock('stats_hash')
    self.stats_hash = mock_stats_hash
    merge_data({metric_spec => NewRelic::MetricData.new(metric_spec, stats, nil)})
    assert_equal(3.0, new_stats.total_call_time)
  end

  def test_merge_data_old_data
    stats = NewRelic::MethodTraceStats.new
    stats.record_data_point(1.0)
    self.expects(:lookup_stats).returns(nil)

    metric_spec = NewRelic::MetricSpec.new('Custom/test/method')
    mock_stats_hash = mock('stats_hash')
    mock_stats_hash.expects(:[]=).with(metric_spec, stats)
    self.stats_hash = mock_stats_hash
    merge_data({metric_spec => NewRelic::MetricData.new(metric_spec, stats, nil)})
  end

end



