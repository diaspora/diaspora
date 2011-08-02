require File.expand_path(File.join(File.dirname(__FILE__),'..', '..','test_helper'))
require 'new_relic/transaction_analysis/segment_summary'
class NewRelic::TransactionAnalysis::SegmentSummaryTest < Test::Unit::TestCase

  def setup
    @sample = mock('sample')
    @ss = NewRelic::TransactionAnalysis::SegmentSummary.new('Controller/foo', @sample)
  end

  # these are mostly stub tests just making sure that the API doesn't
  # change if anyone ever needs to modify it.

  def test_insert
    segment = mock('segment')
    segment.expects(:metric_name).returns('Controller/foo')
    segment.expects(:duration).returns(0.1)
    segment.expects(:exclusive_duration).returns(0.1)
    @ss << segment
    assert_equal 0.1, @ss.total_time
    assert_equal 0.1, @ss.exclusive_time
    assert_equal 1, @ss.call_count
  end

  def test_insert_error
    segment = mock('segment')
    segment.expects(:metric_name).returns('Controller/bar').twice
    assert_raise(ArgumentError) do
      @ss << segment
    end
  end

  def test_average_time
    @ss.total_time = 0.1
    @ss.call_count = 2
    assert_equal 0.05, @ss.average_time
  end

  def test_average_exclusive_time
    @ss.exclusive_time = 0.1
    @ss.call_count = 2
    assert_equal 0.05, @ss.average_exclusive_time
  end

  def test_exclusive_time_percentage_nil
    @ss.exclusive_time = nil
    assert_equal 0, @ss.exclusive_time_percentage
  end

  def test_exclusive_time_percentage
    @ss.exclusive_time = 0.05
    @sample.expects(:duration).returns(0.1).times(3)
    assert_equal 0.5, @ss.exclusive_time_percentage
  end

  def test_total_time_percentage_nil
    @ss.total_time = nil
    assert_equal 0, @ss.total_time_percentage
  end

  def test_total_time_percentage
    @ss.total_time = 0.05
    @sample.expects(:duration).returns(0.1).times(3)
    assert_equal 0.5, @ss.total_time_percentage
  end

  def test_nesting_total_time
    segment = mock('segment')
    segment.expects(:metric_name).twice.returns('Controller/foo')
    segment.expects(:duration).returns(0.1)
    segment.expects(:exclusive_duration).returns(0)
    @ss << segment
    segment.expects(:exclusive_duration).returns(0.1)
    @ss.current_nest_count += 1
    @ss << segment
    assert_equal 0.1, @ss.total_time
    assert_equal 0.1, @ss.exclusive_time
    assert_equal 2, @ss.call_count
  end

  def test_ui_name_default
    @ss.metric_name = 'Remainder'
    assert_equal 'Remainder', @ss.ui_name
  end

  def test_ui_name_lookup
    mocked_object = mock('metric parser obj')
    mocked_object.expects(:developer_name).returns('Developer Name')
    NewRelic::MetricParser::MetricParser.expects(:parse).with('Controller/foo').returns(mocked_object)
    assert_equal 'Developer Name', @ss.ui_name
  end
end
