require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper'))
require 'new_relic/control/class_methods'

class BaseClassMethods
  # stub class to enable testing of the module
  include NewRelic::Control::ClassMethods
end

class NewRelic::Control::ClassMethodsTest < Test::Unit::TestCase
  def setup
    @base = ::BaseClassMethods.new
    super
  end

  def test_instance
    assert_equal(nil, @base.instance_variable_get('@instance'), 'instance should start out nil')
    @base.expects(:new_instance).returns('a new instance')
    assert_equal('a new instance', @base.instance, "should return the result from the #new_instance call")
  end

  def test_new_instance_non_test
    local_env = mock('local env')
    @base.expects(:local_env).returns(local_env).at_least_once
    local_env.expects(:framework).returns('nontest').twice
    mock_klass = mock('klass')
    mock_klass.expects(:new).with(local_env)
    @base.expects(:load_framework_class).with('nontest').returns(mock_klass)
    @base.new_instance
  end
  
  def test_new_instance_test_framework
    local_env = mock('local env')
    local_env.expects(:framework).returns(:test)
    @base.expects(:local_env).returns(local_env)
    @base.expects(:load_test_framework)
    @base.new_instance
  end

  def test_load_test_framework
    local_env = mock('local env')
    # a loose requirement here because the tests will *all* break if
    # this does not work.
    NewRelic::Control::Frameworks::Test.expects(:new).with(local_env, instance_of(String))
    @base.expects(:local_env).returns(local_env)
    @base.load_test_framework
  end

  def test_load_framework_class_existing
    %w[rails rails3 sinatra ruby merb external].each do |type|
      @base.load_framework_class(type)
    end
  end
  
  def test_load_framework_class_missing
    # this is used to allow other people to insert frameworks without
    # having the file in our agent, i.e. define your own
    # NewRelic::Control::Framework::FooBar
    assert_raise(NameError) do
      @base.load_framework_class('missing')
    end
  end
end
