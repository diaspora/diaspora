require "utils"
require 'capistrano/configuration/roles'
require 'capistrano/server_definition'

class ConfigurationRolesTest < Test::Unit::TestCase
  class MockConfig
    attr_reader :original_initialize_called

    def initialize
      @original_initialize_called = true
    end

    include Capistrano::Configuration::Roles
  end

  def setup
    @config = MockConfig.new
  end

  def test_initialize_should_initialize_roles_collection
    assert @config.original_initialize_called
    assert @config.roles.empty?
  end

  def test_role_should_allow_empty_list
    @config.role :app
    assert @config.roles.keys.include?(:app)
    assert @config.roles[:app].empty?
  end

  def test_role_with_one_argument_should_add_to_roles_collection
    @config.role :app, "app1.capistrano.test"
    assert_equal [:app], @config.roles.keys
    assert_role_equals %w(app1.capistrano.test)
  end

  def test_role_block_returning_single_string_is_added_to_roles_collection
    @config.role :app do
      'app1.capistrano.test'
    end
    assert_role_equals %w(app1.capistrano.test)
  end

  def test_role_with_multiple_arguments_should_add_each_to_roles_collection
    @config.role :app, "app1.capistrano.test", "app2.capistrano.test"
    assert_equal [:app], @config.roles.keys
    assert_role_equals %w(app1.capistrano.test app2.capistrano.test)
  end

  def test_role_with_block_and_strings_should_add_both_to_roles_collection
    @config.role :app, 'app1.capistrano.test' do
      'app2.capistrano.test'
    end
    assert_role_equals %w(app1.capistrano.test app2.capistrano.test)
  end

  def test_role_block_returning_array_should_add_each_to_roles_collection
    @config.role :app do
      ['app1.capistrano.test', 'app2.capistrano.test']
    end
    assert_role_equals %w(app1.capistrano.test app2.capistrano.test)
  end

  def test_role_with_options_should_apply_options_to_each_argument
    @config.role :app, "app1.capistrano.test", "app2.capistrano.test", :extra => :value
    @config.roles[:app].each do |server|
      assert_equal({:extra => :value}, server.options)
    end
  end

  def test_role_with_options_should_apply_options_to_block_results
    @config.role :app, :extra => :value do
      ['app1.capistrano.test', 'app2.capistrano.test']
    end
    @config.roles[:app].each do |server|
      assert_equal({:extra => :value}, server.options)
    end
  end

  def test_options_should_apply_only_to_this_argument_set
    @config.role :app, 'app1.capistrano.test', 'app2.capistrano.test' do
      ['app3.capistrano.test', 'app4.capistrano.test']
    end
    @config.role :app, 'app5.capistrano.test', 'app6.capistrano.test', :extra => :value do
      ['app7.capistrano.test', 'app8.capistrano.test']
    end
    @config.role :app, 'app9.capistrano.test'

    option_hosts = ['app5.capistrano.test', 'app6.capistrano.test', 'app7.capistrano.test', 'app8.capistrano.test']
    @config.roles[:app].each do |server|
      if (option_hosts.include? server.host)
        assert_equal({:extra => :value}, server.options)
      else
        assert_not_equal({:extra => :value}, server.options)
      end
    end
  end

  # Here, the source should be more readable than the method name
  def test_role_block_returns_options_hash_is_merged_with_role_options_argument
    @config.role :app, :first => :one, :second => :two do
      ['app1.capistrano.test', 'app2.capistrano.test', {:second => :please, :third => :three}]
    end
    @config.roles[:app].each do |server|
      assert_equal({:first => :one, :second => :please, :third => :three}, server.options)
    end
  end

  def test_role_block_can_override_role_options_argument
    @config.role :app, :value => :wrong do
      Capistrano::ServerDefinition.new('app.capistrano.test')
    end
    @config.roles[:app].servers
    @config.roles[:app].servers.each do |server|
      assert_not_equal({:value => :wrong}, server.options)
    end
  end

  def test_role_block_can_return_nil
    @config.role :app do
      nil
    end
    assert_role_equals ([])
  end

  def test_role_block_can_return_empty_array
    @config.role :app do
      []
    end
    assert_role_equals ([])
  end

  def test_role_definitions_via_server_should_associate_server_with_roles
    @config.server "www.capistrano.test", :web, :app
    assert_equal %w(www.capistrano.test), @config.roles[:app].map { |s| s.host }
    assert_equal %w(www.capistrano.test), @config.roles[:web].map { |s| s.host }
  end

  private

    def assert_role_equals(list)
      assert_equal list, @config.roles[:app].map { |s| s.host }
    end
end
