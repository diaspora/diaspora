require File.expand_path(File.join(File.dirname(__FILE__),'..', 'test_helper'))
require 'new_relic/transaction_analysis'
class NewRelic::TransactionAnalysisTest < Test::Unit::TestCase
  include NewRelic::TransactionAnalysis

  # these are mostly stub tests just making sure that the API doesn't
  # change if anyone ever needs to modify it.

  def test_database_time
    self.expects(:time_percentage).with(/^Database\/.*/)
    database_time
  end

  def test_render_time
    self.expects(:time_percentage).with(/^View\/.*/)
    render_time
  end

  def test_breakdown_data_default
    root_segment = mock('root_segment')
    # this is for 1.9 compatibility - calling each on something calls
    # #to_a on it - which is fun and exciting
    root_segment.stubs(:to_a).returns([root_segment])
    other_segment = mock('other_segment')
    # this is for 1.9 compatibility - calling each on something calls
    # #to_a on it - which is fun and exciting
    other_segment.stubs(:to_a).returns([other_segment])
    other_segment.expects(:metric_name).twice.returns('Controller/foo')
    other_segment.expects(:duration).returns(0.1)
    other_segment.expects(:exclusive_duration).returns(0.1)
    self.expects(:each_segment_with_nest_tracking).multiple_yields(root_segment, other_segment)
    self.expects(:root_segment).twice.returns(root_segment)
    self.expects(:duration).returns(0.1)
    data = breakdown_data
    assert_equal 'Controller/foo', data[0].metric_name
  end

  # kind of a hairy test, we're making sure that the data is truncated
  # to one element by the limit
  def test_breakdown_data_limit_one
    root_segment = mock('root_segment')
    # this is for 1.9 compatibility - calling each on something calls
    # #to_a on it - which is fun and exciting
    root_segment.stubs(:to_a).returns([root_segment])
    other_segment = mock('other_segment')
    # this is for 1.9 compatibility - calling each on something calls
    # #to_a on it - which is fun and exciting
    other_segment.stubs(:to_a).returns([other_segment])
    other_segment.expects(:metric_name).twice.returns('Controller/foo')
    other_segment.expects(:duration).returns(0.1)
    other_segment.expects(:exclusive_duration).returns(0.1)
    yet_another = mock('another segment')
    # this is for 1.9 compatibility - calling each on something calls
    # #to_a on it - which is fun and exciting
    yet_another.stubs(:to_a).returns([yet_another])
    yet_another.expects(:metric_name).twice.returns('Controller/bar')
    yet_another.expects(:duration).returns(0.2)
    yet_another.expects(:exclusive_duration).returns(0.2)
    self.expects(:each_segment_with_nest_tracking).multiple_yields(root_segment, other_segment, yet_another)
    self.expects(:root_segment).times(3).returns(root_segment)
    self.expects(:duration).returns(0.1)
    data = breakdown_data(1)
    assert_equal 1, data.size
    assert_equal 'Controller/bar', data[0].metric_name
  end

  def test_breakdown_data_remainder
    root_segment = mock('root_segment')
    # this is for 1.9 compatibility - calling each on something calls
    # #to_a on it - which is fun and exciting
    root_segment.stubs(:to_a).returns([root_segment])
    other_segment = mock('other_segment')
    # this is for 1.9 compatibility - calling each on something calls
    # #to_a on it - which is fun and exciting
    other_segment.stubs(:to_a).returns([other_segment])
    other_segment.expects(:metric_name).twice.returns('Controller/foo')
    other_segment.expects(:duration).returns(0.1)
    other_segment.expects(:exclusive_duration).returns(0.1)
    self.expects(:each_segment_with_nest_tracking).multiple_yields(root_segment, other_segment)
    self.expects(:root_segment).twice.returns(root_segment)
    self.expects(:duration).returns(0.2)
    data = breakdown_data
    assert_equal 2, data.size
    assert_equal 'Controller/foo', data[0].metric_name
    assert_equal 'Remainder', data[1].metric_name
  end

  def test_sql_segments_default
    root_segment = mock('root_segment') # a segment with no data
    root_segment.expects(:[]).with(:sql).returns(false)
    root_segment.expects(:[]).with(:sql_obfuscated).returns(false)
    root_segment.expects(:[]).with(:key).returns(nil)
    # this is for 1.9 compatibility - calling each on something calls
    # #to_a on it - which is fun and exciting
    root_segment.stubs(:to_a).returns([root_segment])
    other_segment = mock('other_segment') # a sql segment
    other_segment.expects(:[]).with(:sql).returns(true)
    # this is for 1.9 compatibility - calling each on something calls
    # #to_a on it - which is fun and exciting
    other_segment.stubs(:to_a).returns([other_segment])
    self.expects(:each_segment).multiple_yields(root_segment, other_segment)
    assert_equal [other_segment], sql_segments
  end

  def test_time_percentage_default
    root_segment = mock('root_segment')
    root_segment.expects(:metric_name).returns('ROOT')
    # this is for 1.9 compatibility - calling each on something calls
    # #to_a on it - which is fun and exciting
    root_segment.stubs(:to_a).returns([root_segment])
    other_segment = mock('other_segment')
    other_segment.expects(:metric_name).returns('Controller/foo')
    other_segment.expects(:duration).returns(0.1)
    # this is for 1.9 compatibility - calling each on something calls
    # #to_a on it - which is fun and exciting
    other_segment.stubs(:to_a).returns([other_segment])
    self.expects(:duration).returns(0.2)
    self.expects(:each_segment).multiple_yields(root_segment, other_segment)
    assert_equal 50.0, time_percentage(/Controller\/.*/)
  end
end
