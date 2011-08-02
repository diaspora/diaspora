require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper'))
require 'new_relic/transaction_sample/composite_segment'
class NewRelic::TransactionSample::CompositeSegmentTest < Test::Unit::TestCase
  def test_composite_segment_creation
    fake_segment = mock_segment
    NewRelic::TransactionSample::CompositeSegment.new([fake_segment])
  end

  def test_detail_segments_equals
    fake_segment = mock_segment
    cs = NewRelic::TransactionSample::CompositeSegment.new([fake_segment])

    # note that this is a bare mock
    # nothing should be called on it, for now
    other_fake_segment = mock('other segment')
    cs.detail_segments = [other_fake_segment]

    assert_equal cs.detail_segments, [other_fake_segment]
  end

  private

  @@seg_count = 0
  def mock_segment
    @@seg_count += 1
    segment = mock('segment ' + @@seg_count.to_s)
    segment.expects(:entry_timestamp).returns(Time.now)
    # note the following 'twice' - different than SummarySegment
    segment.expects(:exit_timestamp).returns(Time.now).twice
    segment.expects(:metric_name).returns('Custom/test/metric')
    segment.expects(:called_segments).returns([])
    segment
  end
end

