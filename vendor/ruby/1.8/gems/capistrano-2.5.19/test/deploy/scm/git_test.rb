require "utils"
require 'capistrano/recipes/deploy/scm/git'

class DeploySCMGitTest < Test::Unit::TestCase
  class TestSCM < Capistrano::Deploy::SCM::Git
    default_command "git"
  end

  def setup
    @config = { :repository => "." }
    def @config.exists?(name); key?(name); end

    @source = TestSCM.new(@config)
  end

  def test_head
    assert_equal "HEAD", @source.head
    
    # With :branch
    @config[:branch] = "master"
    assert_equal "master", @source.head
  end

  def test_origin
    assert_equal "origin", @source.origin
    @config[:remote] = "username"
    assert_equal "username", @source.origin
  end

  def test_checkout
    @config[:repository] = "git@somehost.com:project.git"
    dest = "/var/www"
    rev = 'c2d9e79'
    assert_equal "git clone -q git@somehost.com:project.git /var/www && cd /var/www && git checkout -q -b deploy #{rev}", @source.checkout(rev, dest)

    # With :scm_command
    git = "/opt/local/bin/git"
    @config[:scm_command] = git
    assert_equal "#{git} clone -q git@somehost.com:project.git /var/www && cd /var/www && #{git} checkout -q -b deploy #{rev}", @source.checkout(rev, dest)

    # with submodules
    @config[:git_enable_submodules] = true
    assert_equal "#{git} clone -q git@somehost.com:project.git /var/www && cd /var/www && #{git} checkout -q -b deploy #{rev} && #{git} submodule -q init && #{git} submodule -q sync && #{git} submodule -q update", @source.checkout(rev, dest)
  end

  def test_checkout_with_verbose_should_not_use_q_switch
    @config[:repository] = "git@somehost.com:project.git"
    @config[:scm_verbose] = true
    dest = "/var/www"
    rev = 'c2d9e79'
    assert_equal "git clone  git@somehost.com:project.git /var/www && cd /var/www && git checkout  -b deploy #{rev}", @source.checkout(rev, dest)
  end

  def test_diff
    assert_equal "git diff master", @source.diff('master')
    assert_equal "git diff master..branch", @source.diff('master', 'branch')
  end

  def test_log
    assert_equal "git log master..", @source.log('master')
    assert_equal "git log master..branch", @source.log('master', 'branch')
  end

  def test_query_revision
    revision = @source.query_revision('HEAD') do |o|
      assert_equal "git ls-remote . HEAD", o
      "d11006102c07c94e5d54dd0ee63dca825c93ed61\tHEAD"
    end
    assert_equal "d11006102c07c94e5d54dd0ee63dca825c93ed61", revision
  end
  
  def test_query_revision_has_whitespace
    revision = @source.query_revision('HEAD') do |o|
      assert_equal "git ls-remote . HEAD", o
      "d11006102c07c94e5d54dd0ee63dca825c93ed61\tHEAD\r"
    end
    assert_equal "d11006102c07c94e5d54dd0ee63dca825c93ed61", revision
  end

  def test_query_revision_deprecation_error
    assert_raise(ArgumentError) do
      revision = @source.query_revision('origin/release') {}
    end
  end

  def test_command_should_be_backwards_compatible
    # 1.x version of this module used ":git", not ":scm_command"
    @config[:git] = "/srv/bin/git"
    assert_equal "/srv/bin/git", @source.command
  end

  def test_sync
    dest = "/var/www"
    rev = 'c2d9e79'
    assert_equal "cd #{dest} && git fetch -q origin && git reset -q --hard #{rev} && git clean -q -d -x -f", @source.sync(rev, dest)

    # With :scm_command
    git = "/opt/local/bin/git"
    @config[:scm_command] = git
    assert_equal "cd #{dest} && #{git} fetch -q origin && #{git} reset -q --hard #{rev} && #{git} clean -q -d -x -f", @source.sync(rev, dest)

    # with submodules
    @config[:git_enable_submodules] = true
    assert_equal "cd #{dest} && #{git} fetch -q origin && #{git} reset -q --hard #{rev} && #{git} submodule -q init && for mod in `#{git} submodule status | awk '{ print $2 }'`; do #{git} config -f .git/config submodule.${mod}.url `#{git} config -f .gitmodules --get submodule.${mod}.url` && echo Synced $mod; done && #{git} submodule -q sync && #{git} submodule -q update && #{git} clean -q -d -x -f", @source.sync(rev, dest)
  end

  def test_sync_with_remote
    dest = "/var/www"
    rev = 'c2d9e79'
    remote = "username"
    repository = "git@somehost.com:project.git"

    @config[:repository] = repository
    @config[:remote] = remote

    assert_equal "cd #{dest} && git config remote.#{remote}.url #{repository} && git config remote.#{remote}.fetch +refs/heads/*:refs/remotes/#{remote}/* && git fetch -q #{remote} && git reset -q --hard #{rev} && git clean -q -d -x -f", @source.sync(rev, dest)
  end

  def test_shallow_clone
    @config[:repository] = "git@somehost.com:project.git"
    @config[:git_shallow_clone] = 1
    dest = "/var/www"
    rev = 'c2d9e79'
    assert_equal "git clone -q --depth 1 git@somehost.com:project.git /var/www && cd /var/www && git checkout -q -b deploy #{rev}", @source.checkout(rev, dest)
  end

  def test_remote_clone
    @config[:repository] = "git@somehost.com:project.git"
    @config[:remote] = "username"
    dest = "/var/www"
    rev = 'c2d9e79'
    assert_equal "git clone -q -o username git@somehost.com:project.git /var/www && cd /var/www && git checkout -q -b deploy #{rev}", @source.checkout(rev, dest)
  end

  def test_remote_clone_with_submodules
    @config[:repository] = "git@somehost.com:project.git"
    @config[:remote] = "username"
    @config[:git_enable_submodules] = true
    dest = "/var/www"
    rev = 'c2d9e79'
    assert_equal "git clone -q -o username git@somehost.com:project.git /var/www && cd /var/www && git checkout -q -b deploy #{rev} && git submodule -q init && git submodule -q sync && git submodule -q update", @source.checkout(rev, dest)
  end

  # Tests from base_test.rb, makin' sure we didn't break anything up there!
  def test_command_should_default_to_default_command
    assert_equal "git", @source.command
    @source.local { assert_equal "git", @source.command }
  end

  def test_command_should_use_scm_command_if_available
    @config[:scm_command] = "/opt/local/bin/git"
    assert_equal "/opt/local/bin/git", @source.command
  end

  def test_command_should_use_scm_command_in_local_mode_if_local_scm_command_not_set
    @config[:scm_command] = "/opt/local/bin/git"
    @source.local { assert_equal "/opt/local/bin/git", @source.command }
  end

  def test_command_should_use_local_scm_command_in_local_mode_if_local_scm_command_is_set
    @config[:scm_command] = "/opt/local/bin/git"
    @config[:local_scm_command] = "/usr/local/bin/git"
    assert_equal "/opt/local/bin/git", @source.command
    @source.local { assert_equal "/usr/local/bin/git", @source.command }
  end

  def test_command_should_use_default_if_scm_command_is_default
    @config[:scm_command] = :default
    assert_equal "git", @source.command
  end

  def test_command_should_use_default_in_local_mode_if_local_scm_command_is_default
    @config[:scm_command] = "/foo/bar/git"
    @config[:local_scm_command] = :default
    @source.local { assert_equal "git", @source.command }
  end

  def test_local_mode_proxy_should_treat_messages_as_being_in_local_mode
    @config[:scm_command] = "/foo/bar/git"
    @config[:local_scm_command] = :default
    assert_equal "git", @source.local.command
    assert_equal "/foo/bar/git", @source.command
  end
end
