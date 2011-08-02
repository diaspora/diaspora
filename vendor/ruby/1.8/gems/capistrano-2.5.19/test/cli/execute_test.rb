require "utils"
require 'capistrano/cli/execute'

class CLIExecuteTest < Test::Unit::TestCase
  class MockCLI
    attr_reader :options

    def initialize
      @options = {}
    end

    include Capistrano::CLI::Execute
  end

  def setup
    @cli = MockCLI.new
    @logger = stub_everything
    @config = stub(:logger => @logger, :debug= => nil, :dry_run= => nil, :preserve_roles= => nil)
    @config.stubs(:set)
    @config.stubs(:load)
    @config.stubs(:trigger)
    @cli.stubs(:instantiate_configuration).returns(@config)
  end

  def test_execute_should_set_logger_verbosity
    @cli.options[:verbose] = 7
    @logger.expects(:level=).with(7)
    @cli.execute!
  end

  def test_execute_should_set_password
    @cli.options[:password] = "nosoup4u"
    @config.expects(:set).with(:password, "nosoup4u")
    @cli.execute!
  end

  def test_execute_should_set_prevars_before_loading
    @config.expects(:load).never
    @config.expects(:set).with(:stage, "foobar")
    @config.expects(:load).with("standard")
    @cli.options[:pre_vars] = { :stage => "foobar" }
    @cli.execute!
  end

  def test_execute_should_load_sysconf_if_sysconf_set_and_exists
    @cli.options[:sysconf] = "/etc/capistrano.conf"
    @config.expects(:load).with("/etc/capistrano.conf")
    File.expects(:file?).with("/etc/capistrano.conf").returns(true)
    @cli.execute!
  end

  def test_execute_should_not_load_sysconf_when_sysconf_set_and_not_exists
    @cli.options[:sysconf] = "/etc/capistrano.conf"
    File.expects(:file?).with("/etc/capistrano.conf").returns(false)
    @cli.execute!
  end

  def test_execute_should_load_dotfile_if_dotfile_set_and_exists
    @cli.options[:dotfile] = "/home/jamis/.caprc"
    @config.expects(:load).with("/home/jamis/.caprc")
    File.expects(:file?).with("/home/jamis/.caprc").returns(true)
    @cli.execute!
  end

  def test_execute_should_not_load_dotfile_when_dotfile_set_and_not_exists
    @cli.options[:dotfile] = "/home/jamis/.caprc"
    File.expects(:file?).with("/home/jamis/.caprc").returns(false)
    @cli.execute!
  end

  def test_execute_should_load_recipes_when_recipes_are_given
    @cli.options[:recipes] = %w(config/deploy path/to/extra)
    @config.expects(:load).with("config/deploy")
    @config.expects(:load).with("path/to/extra")
    @cli.execute!
  end

  def test_execute_should_set_vars_and_execute_tasks
    @cli.options[:vars] = { :foo => "bar", :baz => "bang" }
    @cli.options[:actions] = %w(first second)
    @config.expects(:set).with(:foo, "bar")
    @config.expects(:set).with(:baz, "bang")
    @config.expects(:find_and_execute_task).with("first", :before => :start, :after => :finish)
    @config.expects(:find_and_execute_task).with("second", :before => :start, :after => :finish)
    @cli.execute!
  end

  def test_execute_should_call_load_and_exit_triggers
    @cli.options[:actions] = %w(first second)
    @config.expects(:find_and_execute_task).with("first", :before => :start, :after => :finish)
    @config.expects(:find_and_execute_task).with("second", :before => :start, :after => :finish)
    @config.expects(:trigger).never
    @config.expects(:trigger).with(:load)
    @config.expects(:trigger).with(:exit)
    @cli.execute!
  end

  def test_execute_should_call_handle_error_when_exceptions_occur
    @config.expects(:load).raises(Exception, "boom")
    @cli.expects(:handle_error).with { |e,| Exception === e }
    @cli.execute!
  end

  def test_execute_should_return_config_instance
    assert_equal @config, @cli.execute!
  end

  def test_instantiate_configuration_should_return_new_configuration_instance
    assert_instance_of Capistrano::Configuration, MockCLI.new.instantiate_configuration
  end

  def test_handle_error_with_auth_error_should_abort_with_message_including_user_name
    @cli.expects(:abort).with { |s| s.include?("jamis") }
    @cli.handle_error(Net::SSH::AuthenticationFailed.new("jamis"))
  end

  def test_handle_error_with_cap_error_should_abort_with_message
    @cli.expects(:abort).with("Wish you were here")
    @cli.handle_error(Capistrano::Error.new("Wish you were here"))
  end

  def test_handle_error_with_other_errors_should_reraise_error
    other_error = Class.new(RuntimeError)
    assert_raises(other_error) { @cli.handle_error(other_error.new("boom")) }
  end

  def test_class_execute_method_should_call_parse_and_execute_with_ARGV
    cli = mock(:execute! => nil)
    MockCLI.expects(:parse).with(ARGV).returns(cli)
    MockCLI.execute
  end
end
