$: << File.join( File.dirname( __FILE__ ), '../lib/')

require 'test/unit'
require 'popen4'

require 'platform'

class POpen4Test < Test::Unit::TestCase

  case Platform::OS
    when :win32
      CMD_SHELL     = "cmd"
      CMD_STDERR    = "ruby -e \"$stderr.puts 'ruby'\""
      CMD_EXIT      = "ruby -e \"$stdout.puts 'ruby'; exit 1\""
    else # unix
      CMD_SHELL     = "sh"
      CMD_STDERR    = "ruby -e '$stderr.puts \"ruby\"'"
      CMD_EXIT      = "ruby -e '$stdout.puts \"ruby\"; exit 1'"
  end
  CMD_GOOD      = "ruby --version"
  CMD_BAD       = CMD_GOOD.reverse

  def test_popen4_block_good_cmd
    assert_nothing_raised do
      POpen4.popen4(CMD_GOOD){ |pout, perr, pin, pid| }
    end
  end

  def test_popen4_block_bad_cmd
    status = nil
    assert_nothing_raised do
      status = POpen4.popen4(CMD_BAD){ |pout, perr, pin, pid| }
    end
    assert_nil status
  end

  def test_popen4_block_status
    status = POpen4.popen4(CMD_GOOD) do |pout, perr, pin, pid|
      assert_kind_of(IO, pin)
      assert_kind_of(IO, pout)
      assert_kind_of(IO, perr)
      assert_kind_of(Fixnum, pid)
    end
    assert_kind_of Process::Status, status
  end

  def test_open4_block_read_stdout
    status = POpen4.popen4(CMD_GOOD) do |pout, perr|
      assert_match(/ruby \d\.\d\.\d/, pout.gets)
    end
    assert_equal 0, status.exitstatus
  end

  def test_open4_block_read_stderr
    status = POpen4.popen4(CMD_STDERR) do |pout, perr|
      assert_match "ruby", perr.gets
    end
    assert_equal 0, status.exitstatus
  end

  def test_open4_block_exitstatus
    status = POpen4.popen4(CMD_EXIT) do |pout, perr|
      assert_match "ruby", pout.gets
    end
    assert_kind_of Process::Status, status
    assert_equal 1, status.exitstatus
  end

  def test_open4_block_write_stdin
    status = POpen4.popen4(CMD_SHELL) do |pout, perr, pin|
      pin.puts CMD_GOOD
      pin.puts "exit"
      pin.close
      assert_match(/ruby \d\.\d\.\d/, pout.readlines.join)
    end
    assert_equal 0, status.exitstatus
  end
end
