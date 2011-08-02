require File.expand_path(File.join(File.dirname(__FILE__),'..', 'test_helper'))
class NewRelic::MetricSpecTest < Test::Unit::TestCase

  def test_equal
    spec1 = NewRelic::MetricSpec.new('Controller')
    spec2 = NewRelic::MetricSpec.new('Controller', nil)

    assert spec1.eql?(NewRelic::MetricSpec.new('Controller'))
    assert spec2.eql?(NewRelic::MetricSpec.new('Controller', nil))
    assert spec1.eql?(spec2)
    assert !spec2.eql?(NewRelic::MetricSpec.new('Controller', '/dude'))
  end

  define_method(:'test_<=>') do
    s1 = NewRelic::MetricSpec.new('ActiveRecord')
    s2 = NewRelic::MetricSpec.new('Controller')
    assert_equal [s1, s2].sort, [s1,s2]
    assert_equal [s2, s1].sort, [s1,s2]

    s1 = NewRelic::MetricSpec.new('Controller', nil)
    s2 = NewRelic::MetricSpec.new('Controller', 'hap')
    assert_equal [s2, s1].sort, [s1, s2]
    assert_equal [s1, s2].sort, [s1, s2]

    s1 = NewRelic::MetricSpec.new('Controller', 'hap')
    s2 = NewRelic::MetricSpec.new('Controller', nil)
    assert_equal [s2, s1].sort, [s2, s1]
    assert_equal [s1, s2].sort, [s2, s1]

    s1 = NewRelic::MetricSpec.new('Controller')
    s2 = NewRelic::MetricSpec.new('Controller')
    assert_equal [s2, s1].sort, [s2, s1] # unchanged due to no sort criteria
    assert_equal [s1, s2].sort, [s1, s2] # unchanged due to no sort criteria

    s1 = NewRelic::MetricSpec.new('Controller', nil)
    s2 = NewRelic::MetricSpec.new('Controller', nil)
    assert_equal [s2, s1].sort, [s2, s1] # unchanged due to no sort criteria
    assert_equal [s1, s2].sort, [s1, s2] # unchanged due to no sort criteria
  end

  # test to make sure the MetricSpec class can serialize to json
  def test_json
    spec = NewRelic::MetricSpec.new("controller", "metric#find")

    import = ::ActiveSupport::JSON.decode(spec.to_json)

    compare_spec(spec, import)

    stats = NewRelic::MethodTraceStats.new

    import = ::ActiveSupport::JSON.decode(stats.to_json)

    compare_stat(stats, import)

    metric_data = NewRelic::MetricData.new(spec, stats, 10)

    import = ::ActiveSupport::JSON.decode(metric_data.to_json)

    compare_metric_data(metric_data, import)
  end

  def test_truncate!
    spec = NewRelic::MetricSpec.new('a', 'b')
    spec.name = "a" * 300
    spec.scope = "b" * 300
    spec.truncate!
    assert_equal("a" * 255, spec.name, "should have shortened the name")
    assert_equal("b" * 255, spec.scope, "should have shortened the scope")
  end

  private

  def compare_spec(spec, import)
    assert_equal 2, import.length
    assert_equal spec.name, import['name']
    assert_equal spec.scope, import['scope']
  end

  def compare_stat(stats, import)
    assert_equal 6, import.length
    assert_equal stats.total_call_time, import['total_call_time']
    assert_equal stats.max_call_time, import['max_call_time']
    assert_equal stats.min_call_time, import['min_call_time']
    assert_equal stats.sum_of_squares, import['sum_of_squares']
    assert_equal stats.call_count, import['call_count']
    assert_equal stats.total_exclusive_time, import['total_exclusive_time']
  end

  def compare_metric_data(metric_data, import)
    assert_equal 3, import.length
    assert_equal metric_data.metric_id, import['metric_id']
    compare_spec(metric_data.metric_spec, import['metric_spec']) unless metric_data.metric_id
    compare_stat(metric_data.stats, import['stats'])
  end
end
