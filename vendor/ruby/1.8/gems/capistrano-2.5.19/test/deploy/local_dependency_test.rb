require "utils"
require 'capistrano/recipes/deploy/local_dependency'

class LocalDependencyTest < Test::Unit::TestCase
  def setup
    @config = { }
    @dependency = Capistrano::Deploy::LocalDependency.new(@config)
  end

  def test_should_use_standard_error_message
    setup_for_one_path_entry(false)
    @dependency.command("cat")
    assert_equal "`cat' could not be found in the path on the local host", @dependency.message
  end

  def test_should_use_alternative_message_if_provided
    setup_for_one_path_entry(false)
    @dependency.command("cat").or("Sorry")
    assert_equal "Sorry", @dependency.message
  end

  def test_env_with_no_path_should_never_find_command
    ENV.expects(:[]).with("PATH").returns(nil)
    assert !@dependency.command("cat").pass?
  end

  def test_env_with_one_path_entry_should_fail_if_command_not_found
    setup_for_one_path_entry(false)
    assert !@dependency.command("cat").pass?
  end

  def test_env_with_one_path_entry_should_pass_if_command_found
    setup_for_one_path_entry(true)
    assert @dependency.command("cat").pass?
  end

  def test_env_with_three_path_entries_should_fail_if_command_not_found
    setup_for_three_path_entries(false)
    assert !@dependency.command("cat").pass?
  end

  def test_env_with_three_path_entries_should_pass_if_command_found
    setup_for_three_path_entries(true)
    assert @dependency.command("cat").pass?
  end

  def test_env_with_one_path_entry_on_windows_should_pass_if_command_found_with_extension
    setup_for_one_path_entry_on_windows(true)
    assert @dependency.command("cat").pass?
  end

  private

  def setup_for_one_path_entry(command_found)
    Capistrano::Deploy::LocalDependency.expects(:on_windows?).returns(false)
    ENV.expects(:[]).with("PATH").returns("/bin")
    File.expects(:executable?).with("/bin/cat").returns(command_found)
  end

  def setup_for_three_path_entries(command_found)
    Capistrano::Deploy::LocalDependency.expects(:on_windows?).returns(false)
    path = %w(/bin /usr/bin /usr/local/bin).join(File::PATH_SEPARATOR)
    ENV.expects(:[]).with("PATH").returns(path)
    File.expects(:executable?).with("/usr/bin/cat").returns(command_found)
    File.expects(:executable?).at_most(1).with("/bin/cat").returns(false)
    File.expects(:executable?).at_most(1).with("/usr/local/bin/cat").returns(false)
  end

  def setup_for_one_path_entry_on_windows(command_found)
    Capistrano::Deploy::LocalDependency.expects(:on_windows?).returns(true)
    ENV.expects(:[]).with("PATH").returns("/cygwin/bin")
    File.stubs(:executable?).returns(false)
    first_executable_extension = Capistrano::Deploy::LocalDependency.windows_executable_extensions.first
    File.expects(:executable?).with("/cygwin/bin/cat#{first_executable_extension}").returns(command_found)
  end
end
