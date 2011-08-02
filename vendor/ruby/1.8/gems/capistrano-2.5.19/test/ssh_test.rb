require "utils"
require 'capistrano/ssh'

class SSHTest < Test::Unit::TestCase
  def setup
    Capistrano::ServerDefinition.stubs(:default_user).returns("default-user")
    @options = { :password => nil,
                 :auth_methods => %w(publickey hostbased),
                 :config => false }
    @server = server("capistrano")
    Net::SSH.stubs(:configuration_for).returns({})
  end

  def test_connect_with_bare_server_without_options_or_config_with_public_key_succeeding_should_only_loop_once
    Net::SSH.expects(:start).with(@server.host, "default-user", @options).returns(success = Object.new)
    assert_equal success, Capistrano::SSH.connect(@server)
  end

  def test_connect_with_bare_server_without_options_with_public_key_failing_should_try_password
    Net::SSH.expects(:start).with(@server.host, "default-user", @options).raises(Net::SSH::AuthenticationFailed)
    Net::SSH.expects(:start).with(@server.host, "default-user", @options.merge(:password => "f4b13n", :auth_methods => %w(password keyboard-interactive))).returns(success = Object.new)
    assert_equal success, Capistrano::SSH.connect(@server, :password => "f4b13n")
  end

  def test_connect_with_bare_server_without_options_public_key_and_password_failing_should_raise_error
    Net::SSH.expects(:start).with(@server.host, "default-user", @options).raises(Net::SSH::AuthenticationFailed)
    Net::SSH.expects(:start).with(@server.host, "default-user", @options.merge(:password => "f4b13n", :auth_methods => %w(password keyboard-interactive))).raises(Net::SSH::AuthenticationFailed)
    assert_raises(Net::SSH::AuthenticationFailed) do
      Capistrano::SSH.connect(@server, :password => "f4b13n")
    end
  end

  def test_connect_with_bare_server_and_user_via_public_key_should_pass_user_to_net_ssh
    Net::SSH.expects(:start).with(@server.host, "jamis", @options).returns(success = Object.new)
    assert_equal success, Capistrano::SSH.connect(@server, :user => "jamis")
  end

  def test_connect_with_bare_server_and_user_via_password_should_pass_user_to_net_ssh
    Net::SSH.expects(:start).with(@server.host, "jamis", @options).raises(Net::SSH::AuthenticationFailed)
    Net::SSH.expects(:start).with(@server.host, "jamis", @options.merge(:password => "f4b13n", :auth_methods => %w(password keyboard-interactive))).returns(success = Object.new)
    assert_equal success, Capistrano::SSH.connect(@server, :user => "jamis", :password => "f4b13n")
  end

  def test_connect_with_bare_server_with_explicit_port_should_pass_port_to_net_ssh
    Net::SSH.expects(:start).with(@server.host, "default-user", @options.merge(:port => 1234)).returns(success = Object.new)
    assert_equal success, Capistrano::SSH.connect(@server, :port => 1234)
  end

  def test_connect_with_server_with_user_should_pass_user_to_net_ssh
    server = server("jamis@capistrano")
    Net::SSH.expects(:start).with(server.host, "jamis", @options).returns(success = Object.new)
    assert_equal success, Capistrano::SSH.connect(server)
  end

  def test_connect_with_server_with_port_should_pass_port_to_net_ssh
    server = server("capistrano:1235")
    Net::SSH.expects(:start).with(server.host, "default-user", @options.merge(:port => 1235)).returns(success = Object.new)
    assert_equal success, Capistrano::SSH.connect(server)
  end

  def test_connect_with_server_with_user_and_port_should_pass_user_and_port_to_net_ssh
    server = server("jamis@capistrano:1235")
    Net::SSH.expects(:start).with(server.host, "jamis", @options.merge(:port => 1235)).returns(success = Object.new)
    assert_equal success, Capistrano::SSH.connect(server)
  end

  def test_connect_with_server_with_other_ssh_options_should_pass_ssh_options_to_net_ssh
    server = server("jamis@capistrano:1235", :ssh_options => { :keys => %w(some_valid_key), :auth_methods => %w(a_method), :hmac => 'none' })
    Net::SSH.expects(:start).with(server.host, "jamis", @options.merge(:port => 1235, :keys => %w(some_valid_key), :auth_methods => %w(a_method), :hmac => 'none' )).returns(success = Object.new)
    assert_equal success, Capistrano::SSH.connect(server)
  end

  def test_connect_with_ssh_options_should_use_ssh_options
    ssh_options = { :username => "JamisMan", :port => 8125, :config => false }
    Net::SSH.expects(:start).with(@server.host, "JamisMan", @options.merge(:port => 8125, :config => false)).returns(success = Object.new)
    assert_equal success, Capistrano::SSH.connect(@server, {:ssh_options => ssh_options})
  end

  def test_connect_with_options_and_ssh_options_should_see_options_override_ssh_options
    ssh_options = { :username => "JamisMan", :port => 8125, :forward_agent => true }
    Net::SSH.expects(:start).with(@server.host, "jamis", @options.merge(:port => 1235, :forward_agent => true)).returns(success = Object.new)
    assert_equal success, Capistrano::SSH.connect(@server, :ssh_options => ssh_options, :user => "jamis", :port => 1235)
  end

  def test_connect_with_ssh_options_should_see_server_options_override_ssh_options
    ssh_options = { :username => "JamisMan", :port => 8125, :forward_agent => true }
    server = server("jamis@capistrano:1235")
    Net::SSH.expects(:start).with(server.host, "jamis", @options.merge(:port => 1235, :forward_agent => true, :config => false)).returns(success = Object.new)
    assert_equal success, Capistrano::SSH.connect(server, {:ssh_options => ssh_options})
  end

  def test_connect_should_add_xserver_accessor_to_connection
    Net::SSH.expects(:start).with(@server.host, "default-user", @options).returns(success = Object.new)
    assert_equal success, Capistrano::SSH.connect(@server)
    assert success.respond_to?(:xserver)
    assert success.respond_to?(:xserver)
    assert_equal success.xserver, @server
  end

  def test_connect_should_not_retry_if_custom_auth_methods_are_given
    Net::SSH.expects(:start).with(@server.host, "default-user", @options.merge(:auth_methods => %w(publickey))).raises(Net::SSH::AuthenticationFailed)
    assert_raises(Net::SSH::AuthenticationFailed) { Capistrano::SSH.connect(@server, :ssh_options => { :auth_methods => %w(publickey) }) }
  end
end
