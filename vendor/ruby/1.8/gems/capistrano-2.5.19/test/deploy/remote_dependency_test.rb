require "utils"
require 'capistrano/recipes/deploy/remote_dependency'

class RemoteDependencyTest < Test::Unit::TestCase
  def setup
    @config = { }
    @dependency = Capistrano::Deploy::RemoteDependency.new(@config)
  end

  def test_should_use_standard_error_message_for_directory
    setup_for_a_configuration_run("test -d /data", false)
    @dependency.directory("/data")
    assert_equal "`/data' is not a directory (host)", @dependency.message
  end

  def test_should_use_standard_error_message_for_file
    setup_for_a_configuration_run("test -f /data/foo.txt", false)
    @dependency.file("/data/foo.txt")
    assert_equal "`/data/foo.txt' is not a file (host)", @dependency.message
  end

  def test_should_use_standard_error_message_for_writable
    setup_for_a_configuration_run("test -w /data/foo.txt", false)
    @dependency.writable("/data/foo.txt")
    assert_equal "`/data/foo.txt' is not writable (host)", @dependency.message
  end

  def test_should_use_standard_error_message_for_command
    setup_for_a_configuration_run("which cat", false)
    @dependency.command("cat")
    assert_equal "`cat' could not be found in the path (host)", @dependency.message
  end

  def test_should_use_standard_error_message_for_gem
    setup_for_a_configuration_gem_run("capistrano", "9.9", false)
    @dependency.gem("capistrano", 9.9)
    assert_equal "gem `capistrano' 9.9 could not be found (host)", @dependency.message
  end

  def test_should_fail_if_directory_not_found
    setup_for_a_configuration_run("test -d /data", false)
    assert !@dependency.directory("/data").pass?
  end

  def test_should_pass_if_directory_found
    setup_for_a_configuration_run("test -d /data", true)
    assert @dependency.directory("/data").pass?
  end

  def test_should_fail_if_file_not_found
    setup_for_a_configuration_run("test -f /data/foo.txt", false)
    assert !@dependency.file("/data/foo.txt").pass?
  end

  def test_should_pas_if_file_found
    setup_for_a_configuration_run("test -f /data/foo.txt", true)
    assert @dependency.file("/data/foo.txt").pass?
  end

  def test_should_fail_if_writable_not_found
    setup_for_a_configuration_run("test -w /data/foo.txt", false)
    assert !@dependency.writable("/data/foo.txt").pass?
  end

  def test_should_pass_if_writable_found
    setup_for_a_configuration_run("test -w /data/foo.txt", true)
    assert @dependency.writable("/data/foo.txt").pass?
  end

  def test_should_fail_if_command_not_found
    setup_for_a_configuration_run("which cat", false)
    assert !@dependency.command("cat").pass?
  end

  def test_should_pass_if_command_found
    setup_for_a_configuration_run("which cat", true)
    assert @dependency.command("cat").pass?
  end

  def test_should_fail_if_gem_not_found
    setup_for_a_configuration_gem_run("capistrano", "9.9", false)
    assert !@dependency.gem("capistrano", 9.9).pass?
  end

  def test_should_pass_if_gem_found
    setup_for_a_configuration_gem_run("capistrano", "9.9", true)
    assert @dependency.gem("capistrano", 9.9).pass?
  end

  def test_should_use_alternative_message_if_provided
    setup_for_a_configuration_run("which cat", false)
    @dependency.command("cat").or("Sorry")
    assert_equal "Sorry (host)", @dependency.message
  end

  private

  def setup_for_a_configuration_run(command, passing)
    expectation = @config.expects(:invoke_command).with(command, {})
    if passing
      expectation.returns(true)
    else
      error = Capistrano::CommandError.new
      error.expects(:hosts).returns(["host"])
      expectation.raises(error)
    end
  end

  def setup_for_a_configuration_gem_run(name, version, passing)
    @config.expects(:fetch).with(:gem_command, "gem").returns("gem")
    find_gem_cmd = "gem specification --version '#{version}' #{name} 2>&1 | awk 'BEGIN { s = 0 } /^name:/ { s = 1; exit }; END { if(s == 0) exit 1 }'"
    setup_for_a_configuration_run(find_gem_cmd, passing)
  end
end
