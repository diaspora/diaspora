require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper'))
require 'new_relic/transaction_sample/fake_segment'
class NewRelic::TransactionSample::FakeSegmentTest < Test::Unit::TestCase
  def test_fake_segment_creation
    assert_nothing_raised do
      NewRelic::TransactionSample::FakeSegment.new(0.1, 'Custom/test/metric', nil)
    end
  end

  def test_parent_segment
    # should be public in this class, but not in the parent class
    s = NewRelic::TransactionSample::FakeSegment.new(0.1, 'Custom/test/metric', nil)
    s.parent_segment = 'foo'
    assert_equal('foo', s.instance_eval { @parent_segment } )
  end
end

