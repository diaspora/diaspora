require "utils"
require 'capistrano/recipes/deploy/scm/base'

class DeploySCMBaseTest < Test::Unit::TestCase
  class TestSCM < Capistrano::Deploy::SCM::Base
    default_command "floopy"
  end

  def setup
    @config = { }
    def @config.exists?(name); key?(name); end

    @source = TestSCM.new(@config)
  end

  def test_command_should_default_to_default_command
    assert_equal "floopy", @source.command
    @source.local { assert_equal "floopy", @source.command }
  end

  def test_command_should_use_scm_command_if_available
    @config[:scm_command] = "/opt/local/bin/floopy"
    assert_equal "/opt/local/bin/floopy", @source.command
  end

  def test_command_should_use_scm_command_in_local_mode_if_local_scm_command_not_set
    @config[:scm_command] = "/opt/local/bin/floopy"
    @source.local { assert_equal "/opt/local/bin/floopy", @source.command }
  end

  def test_command_should_use_local_scm_command_in_local_mode_if_local_scm_command_is_set
    @config[:scm_command] = "/opt/local/bin/floopy"
    @config[:local_scm_command] = "/usr/local/bin/floopy"
    assert_equal "/opt/local/bin/floopy", @source.command
    @source.local { assert_equal "/usr/local/bin/floopy", @source.command }
  end

  def test_command_should_use_default_if_scm_command_is_default
    @config[:scm_command] = :default
    assert_equal "floopy", @source.command
  end

  def test_command_should_use_default_in_local_mode_if_local_scm_command_is_default
    @config[:scm_command] = "/foo/bar/floopy"
    @config[:local_scm_command] = :default
    @source.local { assert_equal "floopy", @source.command }
  end

  def test_local_mode_proxy_should_treat_messages_as_being_in_local_mode
    @config[:scm_command] = "/foo/bar/floopy"
    @config[:local_scm_command] = :default
    assert_equal "floopy", @source.local.command
    assert_equal "/foo/bar/floopy", @source.command
  end
end
