require 'composite_io'
require 'stringio'
require 'test/unit'

class CompositeReadIOTest < Test::Unit::TestCase
  def setup
    @io = CompositeReadIO.new(CompositeReadIO.new(StringIO.new('the '), StringIO.new('quick ')),
            StringIO.new('brown '), StringIO.new('fox'))
  end

  def test_full_read_from_several_ios
    assert_equal 'the quick brown fox', @io.read
  end

  unless RUBY_VERSION < '1.9'
    def test_read_from_multibyte
      utf8    = File.open(File.dirname(__FILE__)+'/multibyte.txt')
      binary  = StringIO.new("\x86")
      @io = CompositeReadIO.new(binary,utf8)
      assert_equal "\x86\xE3\x83\x95\xE3\x82\xA1\xE3\x82\xA4\xE3\x83\xAB\n", @io.read
    end
  end

  def test_partial_read
    assert_equal 'the quick', @io.read(9)
  end

  def test_partial_read_to_boundary
    assert_equal 'the quick ', @io.read(10)
  end

  def test_read_with_size_larger_than_available
    assert_equal 'the quick brown fox', @io.read(32)
  end

  def test_read_into_buffer
    buf = ''
    @io.read(nil, buf)
    assert_equal 'the quick brown fox', buf
  end

  def test_multiple_reads
    assert_equal 'the ', @io.read(4)
    assert_equal 'quic', @io.read(4)
    assert_equal 'k br', @io.read(4)
    assert_equal 'own ', @io.read(4)
    assert_equal 'fox',  @io.read(4)
  end

  def test_read_after_end
    @io.read
    assert_equal "", @io.read
  end

  def test_read_after_end_with_amount
    @io.read(32)
    assert_equal nil, @io.read(32)
  end

  def test_convert_error
    assert_raises(ArgumentError) {
      UploadIO.convert!('tmp.txt', 'text/plain', 'tmp.txt', 'tmp.txt')
    }
  end
end
