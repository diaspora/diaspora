ENV['SKIP_RAILS'] = 'true'
require File.expand_path(File.join(File.dirname(__FILE__),'..', 'test_helper'))
##require "new_relic/stats"

module NewRelic; class TestObjectForStats
                   include Stats
                   attr_accessor :total_call_time
                   attr_accessor :total_exclusive_time
                   attr_accessor :begin_time
                   attr_accessor :end_time
                   attr_accessor :call_count
end; end


class NewRelic::StatsTest < Test::Unit::TestCase

  def test_checked_calculation_standard
    obj = NewRelic::TestObjectForStats.new

    assert_equal(1.0, obj.checked_calculation(1, 1))

  end

  def test_checked_calculation_with_zero
    obj = NewRelic::TestObjectForStats.new
    assert_equal(0.0, obj.checked_calculation(1, 0))
  end

  def test_checked_calculation_should_return_floats
    obj = NewRelic::TestObjectForStats.new
    assert_equal(0.5, obj.checked_calculation(1, 2))
  end

  def test_sum_attributes
    first  = NewRelic::TestObjectForStats.new
    second = mock('other object')
    first.expects(:update_totals).with(second)
    first.expects(:stack_min_max_from).with(second)
    first.expects(:update_boundaries).with(second)
    first.sum_attributes(second)
  end

  def mock_plusequals(first, second, method, first_value, second_value)
    first.expects(method).returns(first_value)
    second.expects(method).returns(second_value)
    first.expects("#{method}=".to_sym).with(first_value + second_value)
  end

  def test_stack_min_max_from
    first  = NewRelic::TestObjectForStats.new
    second = mock('other object')
    mock_plusequals(first, second, :min_call_time, 1.5, 0.5)
    mock_plusequals(first, second, :max_call_time, 1.0, 3.0)

    first.stack_min_max_from(second)
  end

  def test_update_boundaries
    first  = NewRelic::TestObjectForStats.new
    second = mock('other object')

    first.expects(:should_replace_begin_time?).with(second).returns(true)
    first.expects(:should_replace_end_time?).with(second).returns(true)
    first.expects(:begin_time=).with('other_begin_time')
    first.expects(:end_time=).with('other_end_time')

    second.expects(:begin_time).returns('other_begin_time')
    second.expects(:end_time).returns('other_end_time')
    first.update_boundaries(second)
  end

  def test_should_replace_end_time
    first  = NewRelic::TestObjectForStats.new
    second = mock('other object')

    first.expects(:end_time).returns(Time.at(1))
    second.expects(:end_time).returns(Time.at(2))
    assert first.should_replace_end_time?(second), 'should replace end time when the other stat is larger'
  end

  def test_should_replace_begin_time_base
    first  = NewRelic::TestObjectForStats.new
    second = mock('other object')

    first.expects(:begin_time).returns(Time.at(2))
    second.expects(:begin_time).returns(Time.at(1))

    assert first.should_replace_begin_time?(second), 'should replace the begin time when it is larger'
  end

  def test_should_replace_begin_time_empty
    first = NewRelic::TestObjectForStats.new
    second = mock('other object')

    first.expects(:begin_time).returns(Time.at(0))
    second.expects(:begin_time).returns(Time.at(2))

    first.expects(:begin_time).returns(Time.at(0))

    assert first.should_replace_begin_time?(second), "should replace the begin time if self.call_count == 0"
  end

  def test_update_totals
    first = NewRelic::TestObjectForStats.new
    second = mock('other object')

    [:total_call_time, :total_exclusive_time, :sum_of_squares].each do |method|
      mock_plusequals(first, second, method, 2.0, 3.0)
    end

    first.update_totals(second)
  end

  def test_min_time_less
    first = NewRelic::TestObjectForStats.new
    second = mock('other object')

    second.expects(:min_call_time).returns(1.0)
    first.expects(:min_call_time).returns(2.0)
    second.expects(:call_count).returns(1)

    first.min_time_less?(second)
  end

  def test_expand_min_max_to
    first = NewRelic::TestObjectForStats.new
    second = mock('other object')

    first.expects(:min_time_less?).with(second).returns(true)
    first.expects(:max_call_time).returns(3.0)

    second.expects(:min_call_time).returns(1.0)
    second.expects(:max_call_time).returns(4.0).twice

    first.expects(:min_call_time=).with(1.0)
    first.expects(:max_call_time=).with(4.0)

    first.expand_min_max_to(second)
  end



  def test_simple
    stats = NewRelic::MethodTraceStats.new
    validate stats, 0, 0, 0, 0

    assert_equal stats.call_count,0
    stats.trace_call 10
    stats.trace_call 20
    stats.trace_call 30

    validate stats, 3, (10+20+30), 10, 30
  end

  def test_to_s
    s1 = NewRelic::MethodTraceStats.new
    s1.trace_call 10
    assert_equal("[01/01/70 12:00AM UTC, 0.000s;  1 calls   10s]", s1.to_s)
  end

  def test_time_str
    s1 = NewRelic::MethodTraceStats.new
    assert_equal(s1.time_str(10), "10 ms")
    assert_equal(s1.time_str(4999), "4999 ms")
    assert_equal(s1.time_str(5000), "5.00 s")
    assert_equal(s1.time_str(5010), "5.01 s")
    assert_equal(s1.time_str(9999), "10.00 s")
    assert_equal(s1.time_str(10000), "10.0 s")
    assert_equal(s1.time_str(20000), "20.0 s")
  end

  def test_fraction_of
    s1 = NewRelic::MethodTraceStats.new
    s2 = NewRelic::MethodTraceStats.new
    s1.trace_call 10
    s2.trace_call 20
    assert_equal(s1.fraction_of(s2).to_s, 'NaN')
  end

  def test_fraction_of2
    s1 = NewRelic::MethodTraceStats.new
    s1.trace_call 10
    s2 = NewRelic::MethodTraceStats.new
    assert_equal(s1.fraction_of(s2).to_s, 'NaN')
  end

  def test_multiply_by
    s1 = NewRelic::MethodTraceStats.new
    s1.trace_call 10
    assert_equal("[01/01/70 12:00AM UTC, 0.000s; 10 calls   10s]", s1.multiply_by(10).to_s)
  end

  def test_get_apdex
    s1 = NewRelic::MethodTraceStats.new
    s1.trace_call 10
    assert_equal(s1.get_apdex, [1, 10, 10])
  end

  def test_apdex_score
    s1 = NewRelic::MethodTraceStats.new
    s1.trace_call 10
    # FIXME make this test the real logic
    # don't ask me what this means, but it's what's coming out the
    # other end when I actually run it.
    assert_in_delta(s1.apdex_score, 0.285714285714286, 0.0000001)
  end

  def test_as_percentage
    s1 = NewRelic::MethodTraceStats.new
    s1.trace_call 10
    assert_equal(s1.as_percentage, 1000.0)
  end

  def test_calls_per_minute

    s1 = NewRelic::TestObjectForStats.new
    s1.call_count =  1
    s1.begin_time = Time.at(0)
    s1.end_time = Time.at(30)
    assert_equal(s1.calls_per_minute, 2)
  end

  def test_total_call_time_per_minute
    s1 = NewRelic::TestObjectForStats.new
    s1.begin_time = Time.at(0)
    s1.end_time = Time.at(0)
    assert_equal(0, s1.total_call_time_per_minute)
    s1.begin_time = Time.at(0)
    s1.end_time = Time.at(30)
    s1.total_call_time = 10
    assert_equal(20, s1.total_call_time_per_minute)
  end

  def test_time_percentage
    s1 = NewRelic::TestObjectForStats.new
    s1.begin_time = Time.at(0)
    s1.end_time = Time.at(0)
    assert_equal(0, s1.time_percentage)
    s1.total_call_time = 10
    s1.begin_time = Time.at(0)
    s1.end_time = Time.at(30)
    assert_equal((1.0 / 3.0), s1.time_percentage)
    s1.total_call_time = 20
    assert_equal((2.0 / 3.0), s1.time_percentage)
  end

  def test_exclusive_time_percentage
    s1 = NewRelic::TestObjectForStats.new
    s1.begin_time = Time.at(0)
    s1.end_time = Time.at(0)
    assert_equal(0, s1.exclusive_time_percentage)
    s1.total_exclusive_time = 10
    s1.begin_time = Time.at(0)
    s1.end_time = Time.at(30)
    assert_equal((1.0 / 3.0), s1.exclusive_time_percentage)
    s1.total_exclusive_time = 20
    assert_equal((2.0 / 3.0), s1.exclusive_time_percentage)
  end

  def test_sum_merge
    s1 = NewRelic::MethodTraceStats.new
    s2 = NewRelic::MethodTraceStats.new
    s1.trace_call 10
    s2.trace_call 20
    s2.freeze

    validate s1, 1, 10, 10, 10
    validate s2, 1, 20, 20, 20
    s1.sum_merge! s2
    validate s1, 1, (10+20), 10 + 20, 20 + 10
    validate s2, 1, 20, 20, 20
  end

  def test_sum_merge_with_exclusive
    s1 = NewRelic::MethodTraceStats.new
    s2 = NewRelic::MethodTraceStats.new

    s1.trace_call 10, 5
    s2.trace_call 20, 10
    s2.freeze

    validate s1, 1, 10, 10, 10, 5
    validate s2, 1, 20, 20, 20, 10
    s1.sum_merge! s2
    validate s1, 1, (10+20), 10 + 20, 20 + 10, (10+5)
  end

  def test_merge
    s1 = NewRelic::MethodTraceStats.new
    s2 = NewRelic::MethodTraceStats.new

    s1.trace_call 10
    s2.trace_call 20
    s2.freeze

    validate s2, 1, 20, 20, 20
    s3 = s1.merge s2
    validate s3, 2, (10+20), 10, 20
    validate s1, 1, 10, 10, 10
    validate s2, 1, 20, 20, 20

    s1.merge! s2
    validate s1, 2, (10+20), 10, 20
    validate s2, 1, 20, 20, 20
  end

  def test_merge_with_exclusive
    s1 = NewRelic::MethodTraceStats.new

    s2 = NewRelic::MethodTraceStats.new

    s1.trace_call 10, 5
    s2.trace_call 20, 10
    s2.freeze

    validate s2, 1, 20, 20, 20, 10
    s3 = s1.merge s2
    validate s3, 2, (10+20), 10, 20, (10+5)
    validate s1, 1, 10, 10, 10, 5
    validate s2, 1, 20, 20, 20, 10

    s1.merge! s2
    validate s1, 2, (10+20), 10, 20, (5+10)
    validate s2, 1, 20, 20, 20, 10
  end

  def test_merge_array
    s1 = NewRelic::MethodTraceStats.new
    merges = []
    merges << (NewRelic::MethodTraceStats.new.trace_call 1)
    merges << (NewRelic::MethodTraceStats.new.trace_call 1)
    merges << (NewRelic::MethodTraceStats.new.trace_call 1)

    s1.merge! merges
    validate s1, 3, 3, 1, 1
  end

  def test_freeze
    s1 = NewRelic::MethodTraceStats.new

    s1.trace_call 10
    s1.freeze

    begin
      # the following should throw an exception because s1 is frozen
      s1.trace_call 20
      assert false
    rescue StandardError
      assert s1.frozen?
      validate s1, 1, 10, 10, 10
    end
  end

  def test_std_dev
    s = NewRelic::MethodTraceStats.new
    s.trace_call 1
    assert s.standard_deviation == 0

    s = NewRelic::MethodTraceStats.new
    s.trace_call 10
    s.trace_call 10
    s.sum_of_squares = nil
    assert s.standard_deviation == 0

    s = NewRelic::MethodTraceStats.new
    s.trace_call 0.001
    s.trace_call 0.001
    assert s.standard_deviation == 0


    s = NewRelic::MethodTraceStats.new
    s.trace_call 10
    s.trace_call 10
    s.trace_call 10
    s.trace_call 10
    s.trace_call 10
    s.trace_call 10
    assert s.standard_deviation == 0

    s = NewRelic::MethodTraceStats.new
    s.trace_call 4
    s.trace_call 7
    s.trace_call 13
    s.trace_call 16
    s.trace_call 8
    s.trace_call 4
    assert_equal(s.sum_of_squares, 4**2 + 7**2 + 13**2 + 16**2 + 8**2 + 4**2)

    s.trace_call 9
    s.trace_call 3
    s.trace_call 1000
    s.trace_call 4

    # calculated stdev (population, not sample) from a spreadsheet.
    assert_in_delta(s.standard_deviation, 297.76, 0.01)
  end

  def test_std_dev_merge
    s1 = NewRelic::MethodTraceStats.new
    s1.trace_call 4
    s1.trace_call 7

    s2 = NewRelic::MethodTraceStats.new
    s2.trace_call 13
    s2.trace_call 16

    s3 = s1.merge(s2)

    assert_equal(s1.sum_of_squares, 4*4 + 7*7)
    assert_in_delta(s1.standard_deviation, 1.5, 0.01)

    assert_in_delta(s2.standard_deviation, 1.5, 0.01)
    assert_equal(s3.sum_of_squares, 4*4 + 7*7 + 13*13 + 16*16, "check sum of squares")
    assert_in_delta(s3.standard_deviation, 4.743, 0.01)
  end

  private
  def validate (stats, count, total, min, max, exclusive = nil)
    assert_equal stats.call_count, count
    assert_equal stats.total_call_time, total
    assert_equal stats.average_call_time, (count > 0 ? total / count : 0)
    assert_equal stats.min_call_time, min
    assert_equal stats.max_call_time, max
    assert_equal stats.total_exclusive_time, exclusive if exclusive
  end
end
