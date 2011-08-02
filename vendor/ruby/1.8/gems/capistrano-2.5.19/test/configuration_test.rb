require "utils"
require 'capistrano/configuration'

# These tests are only for testing the integration of the various components
# of the Configuration class. To test specific features, please look at the
# tests under test/configuration.

class ConfigurationTest < Test::Unit::TestCase
  def setup
    @config = Capistrano::Configuration.new
  end

  def test_connections_execution_loading_namespaces_roles_and_variables_modules_should_integrate_correctly
    Capistrano::SSH.expects(:connect).with { |s,c| s.host == "www.capistrano.test" && c == @config }.returns(:session)

    process_args = Proc.new do |tree, session, opts|
      tree.fallback.command == "echo 'hello world'" &&
      session == [:session] &&
      opts == { :logger => @config.logger }
    end

    Capistrano::Command.expects(:process).with(&process_args)

    @config.load do
      role :test, "www.capistrano.test"
      set  :message, "hello world"
      namespace :testing do
        task :example, :roles => :test do
          run "echo '#{message}'"
        end
      end
    end

    @config.testing.example
  end

  def test_tasks_in_nested_namespace_should_be_able_to_call_tasks_in_same_namespace
    @config.namespace(:outer) do
      task(:first) { set :called_first, true }
      namespace(:inner) do
        task(:first) { set :called_inner_first, true }
        task(:second) { first }
      end
    end

    @config.outer.inner.second
    assert !@config[:called_first]
    assert @config[:called_inner_first]
  end

  def test_tasks_in_nested_namespace_should_be_able_to_call_tasks_in_parent_namespace
    @config.namespace(:outer) do
      task(:first) { set :called_first, true }
      namespace(:inner) do
        task(:second) { first }
      end
    end

    @config.outer.inner.second
    assert @config[:called_first]
  end

  def test_tasks_in_nested_namespace_should_be_able_to_call_shadowed_tasks_in_parent_namespace
    @config.namespace(:outer) do
      task(:first) { set :called_first, true }
      namespace(:inner) do
        task(:first) { set :called_inner_first, true }
        task(:second) { parent.first }
      end
    end

    @config.outer.inner.second
    assert @config[:called_first]
    assert !@config[:called_inner_first]
  end

  def test_hooks_for_default_task_should_be_found_if_named_after_the_namespace
    @config.namespace(:outer) do
      task(:default) { set :called_default, true }
      task(:before_outer) { set :called_before_outer, true }
      task(:after_outer) { set :called_after_outer, true }
    end
    @config.outer.default
    assert @config[:called_before_outer]
    assert @config[:called_default]
    assert @config[:called_after_outer]
  end
end
