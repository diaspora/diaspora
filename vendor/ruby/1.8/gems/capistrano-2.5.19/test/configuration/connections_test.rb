require "utils"
require 'capistrano/configuration/connections'

class ConfigurationConnectionsTest < Test::Unit::TestCase
  class MockConfig
    attr_reader :original_initialize_called
    attr_reader :values
    attr_accessor :current_task

    def initialize
      @original_initialize_called = true
      @values = {}
    end

    def fetch(*args)
      @values.fetch(*args)
    end

    def [](key)
      @values[key]
    end

    def exists?(key)
      @values.key?(key)
    end

    include Capistrano::Configuration::Connections
  end

  def setup
    @config = MockConfig.new
    @config.stubs(:logger).returns(stub_everything)
    Net::SSH.stubs(:configuration_for).returns({})
    @ssh_options = {
      :user        => "user",
      :port        => 8080,
      :password    => "g00b3r",
      :ssh_options => { :debug => :verbose }
    }
  end

  def test_initialize_should_initialize_collections_and_call_original_initialize
    assert @config.original_initialize_called
    assert @config.sessions.empty?
  end

  def test_connection_factory_should_return_default_connection_factory_instance
    factory = @config.connection_factory
    assert_instance_of Capistrano::Configuration::Connections::DefaultConnectionFactory, factory
  end

  def test_connection_factory_instance_should_be_cached
    assert_same @config.connection_factory, @config.connection_factory
  end

  def test_default_connection_factory_honors_config_options
    server = server("capistrano")
    Capistrano::SSH.expects(:connect).with(server, @config).returns(:session)
    assert_equal :session, @config.connection_factory.connect_to(server)
  end

  def test_should_connect_through_gateway_if_gateway_variable_is_set
    @config.values[:gateway] = "j@gateway"
    Net::SSH::Gateway.expects(:new).with("gateway", "j", :password => nil, :auth_methods => %w(publickey hostbased), :config => false).returns(stub_everything)
    assert_instance_of Capistrano::Configuration::Connections::GatewayConnectionFactory, @config.connection_factory
  end

  def test_connection_factory_as_gateway_should_honor_config_options
    @config.values[:gateway] = "gateway"
    @config.values.update(@ssh_options)
    Net::SSH::Gateway.expects(:new).with("gateway", "user", :debug => :verbose, :port => 8080, :password => nil, :auth_methods => %w(publickey hostbased), :config => false).returns(stub_everything)
    assert_instance_of Capistrano::Configuration::Connections::GatewayConnectionFactory, @config.connection_factory
  end
  
  def test_connection_factory_as_gateway_should_chain_gateways_if_gateway_variable_is_an_array
    @config.values[:gateway] = ["j@gateway1", "k@gateway2"]
    gateway1 = mock
    Net::SSH::Gateway.expects(:new).with("gateway1", "j", :password => nil, :auth_methods => %w(publickey hostbased), :config => false).returns(gateway1)
    gateway1.expects(:open).returns(65535)
    Net::SSH::Gateway.expects(:new).with("127.0.0.1", "k", :port => 65535, :password => nil, :auth_methods => %w(publickey hostbased), :config => false).returns(stub_everything)
    assert_instance_of Capistrano::Configuration::Connections::GatewayConnectionFactory, @config.connection_factory
  end
  
  def test_connection_factory_as_gateway_should_share_gateway_between_connections
    @config.values[:gateway] = "j@gateway"
    Net::SSH::Gateway.expects(:new).once.with("gateway", "j", :password => nil, :auth_methods => %w(publickey hostbased), :config => false).returns(stub_everything)
    Capistrano::SSH.stubs(:connect).returns(stub_everything)
    assert_instance_of Capistrano::Configuration::Connections::GatewayConnectionFactory, @config.connection_factory
    @config.establish_connections_to(server("capistrano"))
    @config.establish_connections_to(server("another"))
  end

  def test_establish_connections_to_should_accept_a_single_nonarray_parameter
    Capistrano::SSH.expects(:connect).with { |s,| s.host == "capistrano" }.returns(:success)
    assert @config.sessions.empty?
    @config.establish_connections_to(server("capistrano"))
    assert ["capistrano"], @config.sessions.keys
  end

  def test_establish_connections_to_should_accept_an_array
    Capistrano::SSH.expects(:connect).times(3).returns(:success)
    assert @config.sessions.empty?
    @config.establish_connections_to(%w(cap1 cap2 cap3).map { |s| server(s) })
    assert %w(cap1 cap2 cap3), @config.sessions.keys.sort
  end

  def test_establish_connections_to_should_not_attempt_to_reestablish_existing_connections
    Capistrano::SSH.expects(:connect).times(2).returns(:success)
    @config.sessions[server("cap1")] = :ok
    @config.establish_connections_to(%w(cap1 cap2 cap3).map { |s| server(s) })
    assert %w(cap1 cap2 cap3), @config.sessions.keys.sort.map { |s| s.host }
  end
  
  def test_establish_connections_to_should_raise_one_connection_error_on_failure
    Capistrano::SSH.expects(:connect).times(2).raises(Exception)
    assert_raises(Capistrano::ConnectionError) {
      @config.establish_connections_to(%w(cap1 cap2).map { |s| server(s) })
    }
  end

  def test_connection_error_should_include_accessor_with_host_array
    Capistrano::SSH.expects(:connect).times(2).raises(Exception)

    begin
      @config.establish_connections_to(%w(cap1 cap2).map { |s| server(s) })
      flunk "expected an exception to be raised"
    rescue Capistrano::ConnectionError => e
      assert e.respond_to?(:hosts)
      assert_equal %w(cap1 cap2), e.hosts.map { |h| h.to_s }.sort
    end
  end
  
  def test_connection_error_should_only_include_failed_hosts
    Capistrano::SSH.expects(:connect).with(server('cap1'), anything).raises(Exception)
    Capistrano::SSH.expects(:connect).with(server('cap2'), anything).returns(:success)

    begin
      @config.establish_connections_to(%w(cap1 cap2).map { |s| server(s) })
      flunk "expected an exception to be raised"
    rescue Capistrano::ConnectionError => e
      assert_equal %w(cap1), e.hosts.map { |h| h.to_s }
    end
  end

  def test_execute_on_servers_should_require_a_block
    assert_raises(ArgumentError) { @config.execute_on_servers }
  end

  def test_execute_on_servers_without_current_task_should_call_find_servers
    list = [server("first"), server("second")]
    @config.expects(:find_servers).with(:a => :b, :c => :d).returns(list)
    @config.expects(:establish_connections_to).with(list).returns(:done)
    @config.execute_on_servers(:a => :b, :c => :d) do |result|
      assert_equal list, result
    end
  end

  def test_execute_on_servers_without_current_task_should_raise_error_if_no_matching_servers
    @config.expects(:find_servers).with(:a => :b, :c => :d).returns([])
    assert_raises(Capistrano::NoMatchingServersError) { @config.execute_on_servers(:a => :b, :c => :d) { |list| } }
  end

  def test_execute_on_servers_should_raise_an_error_if_the_current_task_has_no_matching_servers_by_default
    @config.current_task = mock_task
    @config.expects(:find_servers_for_task).with(@config.current_task, {}).returns([])
    assert_raises(Capistrano::NoMatchingServersError) do
      @config.execute_on_servers do
        flunk "should not get here"
      end
    end
  end
  
  def test_execute_on_servers_should_determine_server_list_from_active_task
    assert @config.sessions.empty?
    @config.current_task = mock_task
    @config.expects(:find_servers_for_task).with(@config.current_task, {}).returns([server("cap1"), server("cap2"), server("cap3")])
    Capistrano::SSH.expects(:connect).times(3).returns(:success)
    @config.execute_on_servers {}
    assert_equal %w(cap1 cap2 cap3), @config.sessions.keys.sort.map { |s| s.host }
  end

  def test_execute_on_servers_should_yield_server_list_to_block
    assert @config.sessions.empty?
    @config.current_task = mock_task
    @config.expects(:find_servers_for_task).with(@config.current_task, {}).returns([server("cap1"), server("cap2"), server("cap3")])
    Capistrano::SSH.expects(:connect).times(3).returns(:success)
    block_called = false
    @config.execute_on_servers do |servers|
      block_called = true
      assert servers.detect { |s| s.host == "cap1" }
      assert servers.detect { |s| s.host == "cap2" }
      assert servers.detect { |s| s.host == "cap3" }
      assert servers.all? { |s| @config.sessions[s] }
    end
    assert block_called
  end

  def test_execute_on_servers_with_once_option_should_establish_connection_to_and_yield_only_the_first_server
    assert @config.sessions.empty?
    @config.current_task = mock_task
    @config.expects(:find_servers_for_task).with(@config.current_task, :once => true).returns([server("cap1"), server("cap2"), server("cap3")])
    Capistrano::SSH.expects(:connect).returns(:success)
    block_called = false
    @config.execute_on_servers(:once => true) do |servers|
      block_called = true
      assert_equal %w(cap1), servers.map { |s| s.host }
    end
    assert block_called
    assert_equal %w(cap1), @config.sessions.keys.sort.map { |s| s.host }
  end
  
  def test_execute_servers_should_raise_connection_error_on_failure_by_default
    @config.current_task = mock_task
    @config.expects(:find_servers_for_task).with(@config.current_task, {}).returns([server("cap1")])
    Capistrano::SSH.expects(:connect).raises(Exception)
    assert_raises(Capistrano::ConnectionError) do
      @config.execute_on_servers do
        flunk "expected an exception to be raised"
      end
    end
  end
  
  def test_execute_servers_should_not_raise_connection_error_on_failure_with_on_errors_continue
    @config.current_task = mock_task(:on_error => :continue)
    @config.expects(:find_servers_for_task).with(@config.current_task, {}).returns([server("cap1"), server("cap2")])
    Capistrano::SSH.expects(:connect).with(server('cap1'), anything).raises(Exception)
    Capistrano::SSH.expects(:connect).with(server('cap2'), anything).returns(:success)
    assert_nothing_raised {
      @config.execute_on_servers do |servers|
        assert_equal %w(cap2), servers.map { |s| s.host }
      end
    }
  end
  
  def test_execute_on_servers_should_not_try_to_connect_to_hosts_with_connection_errors_with_on_errors_continue
    list = [server("cap1"), server("cap2")]
    @config.current_task = mock_task(:on_error => :continue)
    @config.expects(:find_servers_for_task).with(@config.current_task, {}).returns(list)
    Capistrano::SSH.expects(:connect).with(server('cap1'), anything).raises(Exception)
    Capistrano::SSH.expects(:connect).with(server('cap2'), anything).returns(:success)
    @config.execute_on_servers do |servers|
      assert_equal %w(cap2), servers.map { |s| s.host }
    end
    @config.expects(:find_servers_for_task).with(@config.current_task, {}).returns(list)
    @config.execute_on_servers do |servers|
      assert_equal %w(cap2), servers.map { |s| s.host }
    end
  end
  
  def test_execute_on_servers_should_not_try_to_connect_to_hosts_with_command_errors_with_on_errors_continue
    cap1 = server("cap1")
    cap2 = server("cap2")
    @config.current_task = mock_task(:on_error => :continue)
    @config.expects(:find_servers_for_task).with(@config.current_task, {}).returns([cap1, cap2])
    Capistrano::SSH.expects(:connect).times(2).returns(:success)
    @config.execute_on_servers do |servers|
      error = Capistrano::CommandError.new
      error.hosts = [cap1]
      raise error
    end
    @config.expects(:find_servers_for_task).with(@config.current_task, {}).returns([cap1, cap2])
    @config.execute_on_servers do |servers|
      assert_equal %w(cap2), servers.map { |s| s.host }
    end
  end
  
  def test_execute_on_servers_should_not_try_to_connect_to_hosts_with_transfer_errors_with_on_errors_continue
    cap1 = server("cap1")
    cap2 = server("cap2")
    @config.current_task = mock_task(:on_error => :continue)
    @config.expects(:find_servers_for_task).with(@config.current_task, {}).returns([cap1, cap2])
    Capistrano::SSH.expects(:connect).times(2).returns(:success)
    @config.execute_on_servers do |servers|
      error = Capistrano::TransferError.new
      error.hosts = [cap1]
      raise error
    end
    @config.expects(:find_servers_for_task).with(@config.current_task, {}).returns([cap1, cap2])
    @config.execute_on_servers do |servers|
      assert_equal %w(cap2), servers.map { |s| s.host }
    end
  end
  
  def test_connect_should_establish_connections_to_all_servers_in_scope
    assert @config.sessions.empty?
    @config.current_task = mock_task
    @config.expects(:find_servers_for_task).with(@config.current_task, {}).returns([server("cap1"), server("cap2"), server("cap3")])
    Capistrano::SSH.expects(:connect).times(3).returns(:success)
    @config.connect!
    assert_equal %w(cap1 cap2 cap3), @config.sessions.keys.sort.map { |s| s.host }
  end
  
  def test_execute_on_servers_should_only_run_on_tasks_max_hosts_hosts_at_once
    cap1 = server("cap1")
    cap2 = server("cap2")
    connection1 = mock()
    connection2 = mock()
    connection1.expects(:close)
    connection2.expects(:close)
    @config.current_task = mock_task(:max_hosts => 1)
    @config.expects(:find_servers_for_task).with(@config.current_task, {}).returns([cap1, cap2])
    Capistrano::SSH.expects(:connect).times(2).returns(connection1).then.returns(connection2)
    block_called = 0
    @config.execute_on_servers do |servers|
      block_called += 1
      assert_equal 1, servers.size
    end
    assert_equal 2, block_called
  end
  
  def test_execute_on_servers_should_only_run_on_max_hosts_hosts_at_once
    cap1 = server("cap1")
    cap2 = server("cap2")
    connection1 = mock()
    connection2 = mock()
    connection1.expects(:close)
    connection2.expects(:close)
    @config.current_task = mock_task(:max_hosts => 1)
    @config.expects(:find_servers_for_task).with(@config.current_task, {}).returns([cap1, cap2])
    Capistrano::SSH.expects(:connect).times(2).returns(connection1).then.returns(connection2)
    block_called = 0
    @config.execute_on_servers do |servers|
      block_called += 1
      assert_equal 1, servers.size
    end
    assert_equal 2, block_called
  end
  
  def test_connect_should_honor_once_option
    assert @config.sessions.empty?
    @config.current_task = mock_task
    @config.expects(:find_servers_for_task).with(@config.current_task, :once => true).returns([server("cap1"), server("cap2"), server("cap3")])
    Capistrano::SSH.expects(:connect).returns(:success)
    @config.connect! :once => true
    assert_equal %w(cap1), @config.sessions.keys.sort.map { |s| s.host }
  end

  private

    def mock_task(options={})
      continue_on_error = options[:on_error] == :continue
      stub("task",
        :fully_qualified_name => "name",
        :options => options,
        :continue_on_error? => continue_on_error,
        :max_hosts => options[:max_hosts]
      )
    end
end
