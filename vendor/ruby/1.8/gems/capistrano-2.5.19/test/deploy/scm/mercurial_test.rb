require "utils"
require 'capistrano/recipes/deploy/scm/mercurial'

class DeploySCMMercurialTest < Test::Unit::TestCase
  class TestSCM < Capistrano::Deploy::SCM::Mercurial
    default_command "hg"
  end

  def setup
    @config = { }
    def @config.exists?(name); key?(name); end

    @source = TestSCM.new(@config)
  end

  def test_head
    assert_equal "tip", @source.head
  end

  def test_different_head
    @config[:branch] = "staging"
    assert_equal "staging", @source.head
  end

  def test_checkout
    @config[:repository] = "http://example.com/project-hg"
    dest = "/var/www"
    assert_equal "hg clone --noupdate http://example.com/project-hg /var/www && hg update --repository /var/www --clean 8a8e00b8f11b", @source.checkout('8a8e00b8f11b', dest)
  end

  def test_diff
    assert_equal "hg diff --rev tip", @source.diff('tip')
    assert_equal "hg diff --rev 1 --rev 2", @source.diff('1', '2')
  end

  def test_log
    assert_equal "hg log --rev 8a8e00b8f11b", @source.log('8a8e00b8f11b')
    assert_equal "hg log --rev 0:3", @source.log('0', '3')
  end

  def test_query_revision
    assert_equal "hg log -r 8a8e00b8f11b --template '{node|short}'", @source.query_revision('8a8e00b8f11b') { |o| o }
  end

  def test_username_should_be_backwards_compatible
    # older versions of this module required :scm_user var instead
    # of the currently preferred :scm_username
    require 'capistrano/logger'
    @config[:scm_user] = "fred"
    text = "user:"
    assert_equal "fred\n", @source.handle_data(mock_state, :test_stream, text)
    # :scm_username takes priority
    @config[:scm_username] = "wilma"
    assert_equal "wilma\n", @source.handle_data(mock_state, :test_stream, text)
  end

  def test_sync
    dest = "/var/www"
    assert_equal "hg pull --repository /var/www && hg update --repository /var/www --clean 8a8e00b8f11b", @source.sync('8a8e00b8f11b', dest)

    # With :scm_command
    @config[:scm_command] = "/opt/local/bin/hg"
    assert_equal "/opt/local/bin/hg pull --repository /var/www && /opt/local/bin/hg update --repository /var/www --clean 8a8e00b8f11b", @source.sync('8a8e00b8f11b', dest)
  end
  
  def test_export
    dest = "/var/www"
    assert_raise(NotImplementedError) { @source.export('8a8e00b8f11b', dest) }
  end
  
  def test_sends_password_if_set
    require 'capistrano/logger'
    text = "password:"
    @config[:scm_password] = "opensesame"
    assert_equal "opensesame\n", @source.handle_data(mock_state, :test_stream, text)
  end
  
  def test_prompts_for_password_if_preferred
    require 'capistrano/logger'
    require 'capistrano/cli'
    Capistrano::CLI.stubs(:password_prompt).with("hg password: ").returns("opensesame")
    @config[:scm_prefer_prompt] = true
    text = "password:"
    assert_equal "opensesame\n", @source.handle_data(mock_state, :test_stream, text)
  end


  # Tests from base_test.rb, makin' sure we didn't break anything up there!
  def test_command_should_default_to_default_command
    assert_equal "hg", @source.command
    @source.local { assert_equal "hg", @source.command }
  end

  def test_command_should_use_scm_command_if_available
    @config[:scm_command] = "/opt/local/bin/hg"
    assert_equal "/opt/local/bin/hg", @source.command
  end

  def test_command_should_use_scm_command_in_local_mode_if_local_scm_command_not_set
    @config[:scm_command] = "/opt/local/bin/hg"
    @source.local { assert_equal "/opt/local/bin/hg", @source.command }
  end

  def test_command_should_use_local_scm_command_in_local_mode_if_local_scm_command_is_set
    @config[:scm_command] = "/opt/local/bin/hg"
    @config[:local_scm_command] = "/usr/local/bin/hg"
    assert_equal "/opt/local/bin/hg", @source.command
    @source.local { assert_equal "/usr/local/bin/hg", @source.command }
  end

  def test_command_should_use_default_if_scm_command_is_default
    @config[:scm_command] = :default
    assert_equal "hg", @source.command
  end

  def test_command_should_use_default_in_local_mode_if_local_scm_command_is_default
    @config[:scm_command] = "/foo/bar/hg"
    @config[:local_scm_command] = :default
    @source.local { assert_equal "hg", @source.command }
  end

  def test_local_mode_proxy_should_treat_messages_as_being_in_local_mode
    @config[:scm_command] = "/foo/bar/hg"
    @config[:local_scm_command] = :default
    assert_equal "hg", @source.local.command
    assert_equal "/foo/bar/hg", @source.command
  end

  private

    def mock_state
      { :channel => { :host => "abc" } }
    end
end
