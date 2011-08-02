require 'common'

class FileOperationsTest < Net::SFTP::TestCase
  def setup
    @sftp = mock("sftp")
    @file = Net::SFTP::Operations::File.new(@sftp, "handle")
    @save_dollar_fslash, $/ = $/, "\n"
    @save_dollar_bslash, $\ = $\, nil
  end

  def teardown
    $/ = @save_dollar_fslash
    $\ = @save_dollar_bslash
  end

  def test_pos_assignment_should_set_position
    @file.pos = 15
    assert_equal 15, @file.pos
  end

  def test_pos_assignment_should_reset_eof
    @sftp.expects(:read!).with("handle", 0, 8192).returns(nil)
    assert !@file.eof?
    @file.read
    assert @file.eof?
    @file.pos = 0
    assert !@file.eof?
  end

  def test_close_should_close_handle_and_set_handle_to_nil
    assert_equal "handle", @file.handle
    @sftp.expects(:close!).with("handle")
    @file.close
    assert_nil @file.handle
  end

  def test_eof_should_be_false_if_at_eof_but_data_remains_in_buffer
    @sftp.expects(:read!).returns("hello world", nil)
    @file.read(1)
    assert !@file.eof?
  end

  def test_eof_should_be_true_if_at_eof_and_no_data_in_buffer
    @sftp.expects(:read!).times(2).returns("hello world", nil)
    @file.read
    assert @file.eof?
  end

  def test_read_without_argument_should_read_and_return_remainder_of_file_and_set_pos
    @sftp.expects(:read!).times(2).returns("hello world", nil)
    assert_equal "hello world", @file.read
    assert_equal 11, @file.pos
  end

  def test_read_with_argument_should_read_and_return_n_bytes_and_set_pos
    @sftp.expects(:read!).returns("hello world")
    assert_equal "hello", @file.read(5)
    assert_equal 5, @file.pos
  end

  def test_read_after_pos_assignment_should_read_from_specified_position
    @sftp.expects(:read!).with("handle", 5, 8192).returns("hello world")
    @file.pos = 5
    assert_equal "hello", @file.read(5)
    assert_equal 10, @file.pos
  end

  def test_gets_without_argument_should_read_until_first_dollar_fslash
    @sftp.expects(:read!).returns("hello world\ngoodbye world\n\nfarewell!\n")
    assert_equal "\n", $/
    assert_equal "hello world\n", @file.gets
    assert_equal 12, @file.pos
  end

  def test_gets_with_empty_argument_should_read_until_double_dollar_fslash
    @sftp.expects(:read!).returns("hello world\ngoodbye world\n\nfarewell!\n")
    assert_equal "\n", $/
    assert_equal "hello world\ngoodbye world\n\n", @file.gets("")
    assert_equal 27, @file.pos
  end

  def test_gets_with_argument_should_read_until_first_instance_of_argument
    @sftp.expects(:read!).returns("hello world\ngoodbye world\n\nfarewell!\n")
    assert_equal "hello w", @file.gets("w")
    assert_equal 7, @file.pos
  end

  def test_gets_when_no_such_delimiter_exists_in_stream_should_read_to_EOF
    @sftp.expects(:read!).times(2).returns("hello world\ngoodbye world\n\nfarewell!\n", nil)
    assert_equal "hello world\ngoodbye world\n\nfarewell!\n", @file.gets("X")
    assert @file.eof?
  end

  def test_gets_at_EOF_should_return_nil
    @sftp.expects(:read!).returns(nil)
    assert_nil @file.gets
    assert @file.eof?
  end

  def test_readline_should_raise_exception_on_EOF
    @sftp.expects(:read!).returns(nil)
    assert_raises(EOFError) { @file.readline }
  end

  def test_write_should_write_data_and_increment_pos_and_return_data_length
    @sftp.expects(:write!).with("handle", 0, "hello world")
    assert_equal 11, @file.write("hello world")
    assert_equal 11, @file.pos
  end

  def test_write_after_pos_assignment_should_write_at_position
    @sftp.expects(:write!).with("handle", 15, "hello world")
    @file.pos = 15
    assert_equal 11, @file.write("hello world")
    assert_equal 26, @file.pos
  end

  def test_print_with_no_arguments_should_write_nothing_if_dollar_bslash_is_nil
    assert_nil $\
    @sftp.expects(:write!).never
    @file.print
  end

  def test_print_with_no_arguments_should_write_dollar_bslash_if_dollar_bslash_is_not_nil
    $\ = "-"
    @sftp.expects(:write!).with("handle", 0, "-")
    @file.print
  end

  def test_print_with_arguments_should_write_all_arguments
    @sftp.expects(:write!).with("handle", 0, "hello")
    @sftp.expects(:write!).with("handle", 5, " ")
    @sftp.expects(:write!).with("handle", 6, "world")
    @file.print("hello", " ", "world")
  end

  def test_puts_should_recursively_puts_array_arguments
    10.times do |i|
      @sftp.expects(:write!).with("handle", i*2, i.to_s)
      @sftp.expects(:write!).with("handle", i*2+1, "\n")
    end
    @file.puts 0, [1, [2, 3], 4, [5, [6, 7, 8]]], 9
  end

  def test_puts_should_not_append_newline_if_argument_ends_in_newline
    @sftp.expects(:write!).with("handle", 0, "a")
    @sftp.expects(:write!).with("handle", 1, "\n")
    @sftp.expects(:write!).with("handle", 2, "b\n")
    @sftp.expects(:write!).with("handle", 4, "c")
    @sftp.expects(:write!).with("handle", 5, "\n")
    @file.puts "a", "b\n", "c"
  end

  def test_stat_should_return_attributes_object_for_handle
    stat = stub("stat")
    @sftp.expects(:fstat!).with("handle").returns(stat)
    assert_equal stat, @file.stat
  end
end