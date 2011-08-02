require 'common'
require 'net/ssh/buffered_io'

class TestBufferedIo < Test::Unit::TestCase
  def test_fill_should_pull_from_underlying_io
    io.expects(:recv).with(8192).returns("here is some data")
    assert_equal 17, io.fill
    assert_equal 17, io.available
    assert_equal "here is some data", io.read_available(20)
  end

  def test_enqueue_should_not_write_to_underlying_io
    assert !io.pending_write?
    io.expects(:send).never
    io.enqueue("here is some data")
    assert io.pending_write?
  end

  def test_send_pending_should_not_fail_when_no_writes_are_pending
    assert !io.pending_write?
    io.expects(:send).never
    assert_nothing_raised { io.send_pending }
  end

  def test_send_pending_with_pending_writes_should_write_to_underlying_io
    io.enqueue("here is some data")
    io.expects(:send).with("here is some data", 0).returns(17)
    assert io.pending_write?
    assert_nothing_raised { io.send_pending }
    assert !io.pending_write?
  end

  def test_wait_for_pending_sends_should_write_only_once_if_all_can_be_written_at_once
    io.enqueue("here is some data")
    io.expects(:send).with("here is some data", 0).returns(17)
    assert io.pending_write?
    assert_nothing_raised { io.wait_for_pending_sends }
    assert !io.pending_write?
  end

  def test_wait_for_pending_sends_should_write_multiple_times_if_first_write_was_partial
    io.enqueue("here is some data")

    io.expects(:send).with("here is some data", 0).returns(10)
    io.expects(:send).with("me data", 0).returns(4)
    io.expects(:send).with("ata", 0).returns(3)

    IO.expects(:select).times(2).with(nil, [io]).returns([[], [io]])

    assert_nothing_raised { io.wait_for_pending_sends }
    assert !io.pending_write?
  end

  private

    def io
      @io ||= begin
        io = mock("io")
        io.extend(Net::SSH::BufferedIo)
        io
      end
    end
end