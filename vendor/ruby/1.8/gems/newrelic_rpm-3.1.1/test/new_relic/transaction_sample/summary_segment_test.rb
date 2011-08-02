require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper'))
require 'new_relic/transaction_sample/summary_segment'
class NewRelic::TransactionSample::SummarySegmentTest < Test::Unit::TestCase
  def test_summary_segment_creation
    fake_segment = mock_segment
    NewRelic::TransactionSample::SummarySegment.new(fake_segment)
  end

  def test_add_segments
    fake_segment = mock_segment
    ss = NewRelic::TransactionSample::SummarySegment.new(fake_segment)
    other_fake_segment = mock_segment
    # with the new summary segment
    ss.expects(:add_called_segment).with(instance_of(NewRelic::TransactionSample::SummarySegment))
    ss.add_segments([other_fake_segment])
  end

  private

  @@seg_count = 0
  def mock_segment
    @@seg_count += 1
    segment = mock('segment ' + @@seg_count.to_s)
    segment.expects(:entry_timestamp).returns(Time.now)
    segment.expects(:exit_timestamp).returns(Time.now)
    segment.expects(:metric_name).returns('Custom/test/metric')
    segment.expects(:called_segments).returns([])
    segment
  end
end

