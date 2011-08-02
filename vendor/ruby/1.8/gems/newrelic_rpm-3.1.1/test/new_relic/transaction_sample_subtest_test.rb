class NewRelic::TransactionSample::SubTest < Test::Unit::TestCase
  def setup
    @t = NewRelic::TransactionSample.new

    @t.params[:test] = "hi"

    s1 = @t.create_segment(1.0, "controller")

    @t.root_segment.add_called_segment(s1)

    s2 = @t.create_segment(2.0, "AR1")

    s2.params[:test] = "test"

    s1.add_called_segment(s2)
    s2.end_trace 3.0
    s1.end_trace 4.0

    s3 = @t.create_segment(4.0, "post_filter")
    @t.root_segment.add_called_segment(s3)
    s3.end_trace 6.0

    s4 = @t.create_segment(6.0, "post_filter")
    @t.root_segment.add_called_segment(s4)
    s4.end_trace 7.0
  end

  def test_exclusive_duration
    s1 = @t.root_segment.called_segments.first
    assert_equal 3.0, s1.duration
    assert_equal 2.0, s1.exclusive_duration
  end

  def test_count_the_segments
    assert_equal 4, @t.count_segments
  end

  def test_truncate_long_samples
    @t.truncate(2)
    assert_equal 2, @t.count_segments

    @t = NewRelic::TransactionSample.new

    s1 = @t.create_segment(1.0, "controller")
    @t.root_segment.add_called_segment(s1)

    100.times do
      s1.add_called_segment(@t.create_segment(1.0, "segment"))
    end
    assert_equal 101, @t.count_segments
    @t.truncate(2)
    assert_equal 2, @t.count_segments
    assert_equal 101, @t.params[:segment_count]
  end

end
