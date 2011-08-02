require 'test/unit'
require 'thread'
if RUBY_PLATFORM != "java"
  $:.unshift File.expand_path( File.join( File.dirname( __FILE__ ), "../ext/fastthread" ) )
  require 'fastthread'
end

class TestQueue < Test::Unit::TestCase
  def check_sequence( q )
    range = "a".."f"

    s = ""
    e = nil

    t = Thread.new do
      begin
        for c in range
          q.push c
          s << c
          Thread.pass
        end
      rescue Exception => e
      end
    end

    for c in range
      unless t.alive?
        raise e if e
        assert_equal range.to_a.join, s, "expected all values pushed"
      end
      x = q.shift
      assert_equal c, x, "sequence error: expected #{ c } but got #{ x }"
    end
  end

  def test_queue
    check_sequence( Queue.new )
  end

  def test_sized_queue_full
    check_sequence( SizedQueue.new( 6 ) )
  end

  def test_sized_queue_half
    check_sequence( SizedQueue.new( 3 ) )
  end

  def test_sized_queue_one
    check_sequence( SizedQueue.new( 1 ) )
  end

  def check_serialization( k, *args )
    q1 = k.new *args
    %w(a b c d e f).each { |c| q1.push c }
    q2 = Marshal.load(Marshal.dump(q1))
    assert( ( q1.size == q2.size ), "queues are same size" )
    q1.size.times do
      assert( ( q1.pop == q2.pop ), "same data" )
    end
    [ q1, q2 ]
  end

  def test_queue_serialization
    check_serialization Queue
  end

  def test_sized_queue_serialization
    (q1, q2) = check_serialization SizedQueue, 20
    assert( ( q1.max == q2.max ), "maximum sizes equal" )
  end

  def test_sized_queue_size
    q = SizedQueue.new 3
    assert_equal 3, q.max, "queue has expected max (3)"
    q.max = 5
    assert_equal 5, q.max, "queue has expected max (5)"
  end
end 

