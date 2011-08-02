require "utils"
require 'capistrano'

class ExtensionsTest < Test::Unit::TestCase
  module CustomExtension
    def do_something(command)
      run(command)
    end
  end

  def setup
    @config = Capistrano::Configuration.new
  end

  def teardown
    Capistrano::EXTENSIONS.keys.each { |e| Capistrano.remove_plugin(e) }
  end

  def test_register_plugin_should_add_instance_method_on_configuration_and_return_true
    assert !@config.respond_to?(:custom_stuff)
    assert Capistrano.plugin(:custom_stuff, CustomExtension)
    assert @config.respond_to?(:custom_stuff)
  end

  def test_register_plugin_that_already_exists_should_return_false
    assert Capistrano.plugin(:custom_stuff, CustomExtension)
    assert !Capistrano.plugin(:custom_stuff, CustomExtension)
  end

  def test_register_plugin_with_public_method_name_should_fail
    method = Capistrano::Configuration.public_instance_methods.first
    assert_not_nil method, "need a public instance method for testing"
    assert_raises(Capistrano::Error) { Capistrano.plugin(method, CustomExtension) }
  end

  def test_register_plugin_with_protected_method_name_should_fail
    method = Capistrano::Configuration.protected_instance_methods.first
    assert_not_nil method, "need a protected instance method for testing"
    assert_raises(Capistrano::Error) { Capistrano.plugin(method, CustomExtension) }
  end

  def test_register_plugin_with_private_method_name_should_fail
    method = Capistrano::Configuration.private_instance_methods.first
    assert_not_nil method, "need a private instance method for testing"
    assert_raises(Capistrano::Error) { Capistrano.plugin(method, CustomExtension) }
  end

  def test_unregister_plugin_that_does_not_exist_should_return_false
    assert !Capistrano.remove_plugin(:custom_stuff)
  end

  def test_unregister_plugin_should_remove_method_and_return_true
    assert Capistrano.plugin(:custom_stuff, CustomExtension)
    assert @config.respond_to?(:custom_stuff)
    assert Capistrano.remove_plugin(:custom_stuff)
    assert !@config.respond_to?(:custom_stuff)
  end

  def test_registered_plugin_proxy_should_return_proxy_object
    Capistrano.plugin(:custom_stuff, CustomExtension)
    assert_instance_of Capistrano::ExtensionProxy, @config.custom_stuff
  end

  def test_proxy_object_should_delegate_to_configuration
    Capistrano.plugin(:custom_stuff, CustomExtension)
    @config.expects(:run).with("hello")
    @config.custom_stuff.do_something("hello")
  end
end