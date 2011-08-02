require "utils"
require 'capistrano/configuration'
require 'capistrano/shell'

class ShellTest < Test::Unit::TestCase
  def setup
    @config = Capistrano::Configuration.new
    @shell  = Capistrano::Shell.new(@config)
    @shell.stubs(:puts)
  end

  def test_readline_fallback_prompt_should_write_to_stdout_and_read_from_stdin
    STDOUT.expects(:print).with("prompt> ")
    STDOUT.expects(:flush)
    STDIN.expects(:gets).returns("hi\n")
    assert_equal "hi\n", Capistrano::Shell::ReadlineFallback.readline("prompt> ")
  end

  def test_question_mark_as_input_should_trigger_help
    @shell.expects(:read_line).returns("?")
    @shell.expects(:help)
    assert @shell.read_and_execute
  end

  def test_help_as_input_should_trigger_help
    @shell.expects(:read_line).returns("help")
    @shell.expects(:help)
    assert @shell.read_and_execute
  end

  def test_quit_as_input_should_cause_read_and_execute_to_return_false
    @shell.expects(:read_line).returns("quit")
    assert !@shell.read_and_execute
  end

  def test_exit_as_input_should_cause_read_and_execute_to_return_false
    @shell.expects(:read_line).returns("exit")
    assert !@shell.read_and_execute
  end

  def test_set_should_parse_flag_and_value_and_call_set_option
    @shell.expects(:read_line).returns("set -v 5")
    @shell.expects(:set_option).with("v", "5")
    assert @shell.read_and_execute
  end

  def test_text_without_with_or_on_gets_processed_verbatim
    @shell.expects(:read_line).returns("hello world")
    @shell.expects(:process_command).with(nil, nil, "hello world")
    assert @shell.read_and_execute
  end

  def test_text_with_with_gets_processed_with_with # lol
    @shell.expects(:read_line).returns("with app,db hello world")
    @shell.expects(:process_command).with("with", "app,db", "hello world")
    assert @shell.read_and_execute
  end

  def test_text_with_on_gets_processed_with_on
    @shell.expects(:read_line).returns("on app,db hello world")
    @shell.expects(:process_command).with("on", "app,db", "hello world")
    assert @shell.read_and_execute
  end
  
  def test_task_command_with_bang_gets_processed_by_exec_tasks
    while_testing_post_exec_commands do
      @shell.expects(:read_line).returns("!deploy")
      @shell.expects(:exec_tasks).with(["deploy"])
      assert @shell.read_and_execute
    end
  end
  
  def test_normal_command_gets_processed_by_exec_command
    while_testing_post_exec_commands do
      @shell.expects(:read_line).returns("uptime")
      @shell.expects(:exec_command).with("uptime",nil)
      @shell.expects(:connect)
      assert @shell.read_and_execute
    end
  end
  
  
  private
  
  def while_testing_post_exec_commands(&block)
    @shell.instance_variable_set(:@mutex,Mutex.new)
    yield
  end
  
end
