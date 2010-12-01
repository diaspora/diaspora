# encoding: binary
require './test/test_helper'

class ByteBufferTest < Test::Unit::TestCase
  include BSON

  def setup
    @buf = ByteBuffer.new
  end
  
  def test_initial_state
    assert_equal 0, @buf.position
    assert_equal [], @buf.to_a
    assert_equal "", @buf.to_s
    assert_equal 0, @buf.length
  end

  def test_nil_get_returns_one_byte
    @buf.put_array([1, 2, 3, 4])
    @buf.rewind
    assert_equal 1, @buf.get
  end

  def test_one_get_returns_array_length_one
    @buf.put_array([1, 2, 3, 4])
    @buf.rewind
    assert_equal [1], @buf.get(1)
  end

  def test_zero_get_returns_empty_array
    @buf.put_array([1, 2, 3, 4])
    @buf.rewind
    assert_equal [], @buf.get(0)
  end

  def test_length
    @buf.put_int 3
    assert_equal 4, @buf.length
  end

  def test_default_order
    assert_equal :little_endian, @buf.order
  end

  def test_long_length
    @buf.put_long 1027
    assert_equal 8, @buf.length
  end

  def test_get_long
    @buf.put_long 1027
    @buf.rewind
    assert_equal 1027, @buf.get_long
  end

  def test_get_double
    @buf.put_double 41.2
    @buf.rewind
    assert_equal 41.2, @buf.get_double
  end
  
  if defined?(Encoding)
    def test_serialize_cstr_converts_encoding_to_utf8
      theta = "hello \xC8".force_encoding("ISO-8859-7")
      ByteBuffer.serialize_cstr(@buf, theta)
      assert_equal "hello \xCE\x98\0", @buf.to_s
      assert_equal Encoding.find('binary'), @buf.to_s.encoding
    end
    
    def test_serialize_cstr_validates_data_as_utf8
      assert_raises(Encoding::UndefinedConversionError) do
        ByteBuffer.serialize_cstr(@buf, "hello \xFF")
      end
    end
  else
    def test_serialize_cstr_forces_encoding_to_utf8
      # Unicode snowman (\u2603)
      ByteBuffer.serialize_cstr(@buf, "hello \342\230\203")
      assert_equal "hello \342\230\203\0", @buf.to_s
    end
    
    def test_serialize_cstr_validates_data_as_utf8
      assert_raises(BSON::InvalidStringEncoding) do
        ByteBuffer.serialize_cstr(@buf, "hello \xFF")
      end
    end
  end
  
  def test_put_negative_byte
    @buf.put(-1)
    @buf.rewind
    assert_equal 255, @buf.get
    assert_equal "\xFF", @buf.to_s
  end
  
  def test_put_with_offset
    @buf.put(1)
    @buf.put(2, 0)
    @buf.put(3, 3)
    assert_equal "\x02\x00\x00\x03", @buf.to_s
  end
  
  def test_put_array_with_offset
    @buf.put(1)
    @buf.put_array([2, 3], 0)
    @buf.put_array([4, 5], 4)
    assert_equal "\x02\x03\x00\x00\x04\x05", @buf.to_s
  end
  
  def test_put_int_with_offset
    @buf.put(1)
    @buf.put_int(2, 0)
    @buf.put_int(3, 5)
    assert_equal "\x02\x00\x00\x00\x00\x03\x00\x00\x00", @buf.to_s
  end
  
  def test_put_long_with_offset
    @buf.put(1)
    @buf.put_long(2, 0)
    @buf.put_long(3, 9)
    assert_equal(
      "\x02\x00\x00\x00\x00\x00\x00\x00" +
      "\x00" +
      "\x03\x00\x00\x00\x00\x00\x00\x00",
      @buf.to_s)
  end
  
  def test_put_binary
    @buf.put(1)
    @buf.put_binary("\x02\x03", 0)
    @buf.put_binary("\x04\x05", 4)
    assert_equal "\x02\x03\x00\x00\x04\x05", @buf.to_s
  end
  
  def test_rewrite
    @buf.put_int(0)
    @buf.rewind
    @buf.put_int(1027)
    assert_equal 4, @buf.length
    @buf.rewind
    assert_equal 1027, @buf.get_int
    assert_equal 4, @buf.position
  end

  def test_prepend_byte_buffer
    @buf.put_int(4)
    new_buf = ByteBuffer.new([5, 0, 0, 0])
    @buf.prepend!(new_buf)
    assert_equal [5, 0, 0, 0, 4, 0, 0, 0], @buf.to_a
  end

  def test_append_byte_buffer
    @buf.put_int(4)
    new_buf = ByteBuffer.new([5, 0, 0, 0])
    @buf.append!(new_buf)
    assert_equal [4, 0, 0, 0, 5, 0, 0, 0], @buf.to_a
  end
  
  def test_array_as_initial_input
    @buf = ByteBuffer.new([5, 0, 0, 0])
    assert_equal 4, @buf.size
    assert_equal "\x05\x00\x00\x00", @buf.to_s
    assert_equal [5, 0, 0, 0], @buf.to_a
    @buf.put_int(32)
    @buf.rewind
    assert_equal 5, @buf.get_int
    assert_equal 32, @buf.get_int
  end
  
  def test_binary_string_as_initial_input
    str = "abcd"
    str.force_encoding('binary') if str.respond_to?(:force_encoding)
    @buf = ByteBuffer.new(str)
    assert_equal "abcd", @buf.to_s
    assert_equal [97, 98, 99, 100], @buf.to_a
    @buf.put_int(0)
    assert_equal [97, 98, 99, 100, 0, 0, 0, 0], @buf.to_a
  end
  
  def test_more
    assert !@buf.more?
    @buf.put_int(5)
    assert !@buf.more?
    @buf.rewind
    assert @buf.more?
    @buf.get_int
    assert !@buf.more?
  end

end
