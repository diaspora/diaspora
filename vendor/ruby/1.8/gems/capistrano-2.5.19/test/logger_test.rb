require "utils"
require 'capistrano/logger'
require 'stringio'

class LoggerTest < Test::Unit::TestCase
  def setup
    @io = StringIO.new
    @logger = Capistrano::Logger.new(:output => @io)
  end

  def test_logger_should_use_STDERR_by_default
    logger = Capistrano::Logger.new
    assert_equal STDERR, logger.device
  end

  def test_logger_should_use_output_option_if_output_responds_to_puts
    logger = Capistrano::Logger.new(:output => STDOUT)
    assert_equal STDOUT, logger.device
  end

  def test_logger_should_open_file_if_output_does_not_respond_to_puts
    File.expects(:open).with("logs/capistrano.log", "a").returns(:mock)
    logger = Capistrano::Logger.new(:output => "logs/capistrano.log")
    assert_equal :mock, logger.device
  end

  def test_close_should_not_close_device_if_device_is_default
    logger = Capistrano::Logger.new
    logger.device.expects(:close).never
    logger.close
  end

  def test_close_should_not_close_device_is_device_is_explicitly_given
    logger = Capistrano::Logger.new(:output => STDOUT)
    STDOUT.expects(:close).never
    logger.close
  end

  def test_close_should_close_device_when_device_was_implicitly_opened
    f = mock("file", :close => nil)
    File.expects(:open).with("logs/capistrano.log", "a").returns(f)
    logger = Capistrano::Logger.new(:output => "logs/capistrano.log")
    logger.close
  end

  def test_log_with_level_greater_than_threshold_should_ignore_message
    @logger.level = 3
    @logger.log(4, "message")
    assert @io.string.empty?
  end

  def test_log_with_level_equal_to_threshold_should_log_message
    @logger.level = 3
    @logger.log(3, "message")
    assert @io.string.include?("message")
  end

  def test_log_with_level_less_than_threshold_should_log_message
    @logger.level = 3
    @logger.log(2, "message")
    assert @io.string.include?("message")
  end

  def test_log_with_multiline_message_should_log_each_line_separately
    @logger.log(0, "first line\nsecond line")
    assert @io.string.include?("*** first line")
    assert @io.string.include?("*** second line")
  end

  def test_log_with_line_prefix_should_insert_line_prefix_before_message
    @logger.log(0, "message", "prefix")
    assert @io.string.include?("*** [prefix] message")
  end

  def test_log_with_level_0_should_have_strong_indent
    @logger.log(0, "message")
    assert @io.string.match(/^\*\*\* message/)
  end

  def test_log_with_level_1_should_have_weaker_indent
    @logger.level = 1
    @logger.log(1, "message")
    assert @io.string.match(/^ \*\* message/)
  end

  def test_log_with_level_2_should_have_weaker_indent
    @logger.level = 2
    @logger.log(2, "message")
    assert @io.string.match(/^  \* message/)
  end

  def test_log_with_level_3_should_have_weakest_indent
    @logger.level = 3
    @logger.log(3, "message")
    assert @io.string.match(/^    message/)
  end

  def test_important_should_delegate_to_log_with_level_IMPORTANT
    @logger.expects(:log).with(Capistrano::Logger::IMPORTANT, "message", "prefix")
    @logger.important("message", "prefix")
  end

  def test_info_should_delegate_to_log_with_level_INFO
    @logger.expects(:log).with(Capistrano::Logger::INFO, "message", "prefix")
    @logger.info("message", "prefix")
  end

  def test_debug_should_delegate_to_log_with_level_DEBUG
    @logger.expects(:log).with(Capistrano::Logger::DEBUG, "message", "prefix")
    @logger.debug("message", "prefix")
  end

  def test_trace_should_delegate_to_log_with_level_TRACE
    @logger.expects(:log).with(Capistrano::Logger::TRACE, "message", "prefix")
    @logger.trace("message", "prefix")
  end

  def test_ordering_of_levels
    assert Capistrano::Logger::IMPORTANT < Capistrano::Logger::INFO
    assert Capistrano::Logger::INFO < Capistrano::Logger::DEBUG
    assert Capistrano::Logger::DEBUG < Capistrano::Logger::TRACE
  end
end
