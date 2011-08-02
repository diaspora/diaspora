require "utils"
require 'capistrano/configuration/callbacks'

class ConfigurationCallbacksTest < Test::Unit::TestCase
  class MockConfig
    attr_reader :original_initialize_called
    attr_reader :called

    def initialize
      @original_initialize_called = true
      @called = []
    end

    def execute_task(task)
      invoke_task_directly(task)
    end

    protected

      def invoke_task_directly(task)
        @called << task
      end

    include Capistrano::Configuration::Callbacks
  end

  def setup
    @config = MockConfig.new
    @config.stubs(:logger).returns(stub_everything("logger"))
  end

  def test_initialize_should_initialize_callbacks_collection
    assert @config.original_initialize_called
    assert @config.callbacks.empty?
  end

  def test_before_should_delegate_to_on
    @config.expects(:on).with(:before, :foo, "bing:blang", {:only => :bar, :zip => :zing})
    @config.before :bar, :foo, "bing:blang", :zip => :zing
  end

  def test_after_should_delegate_to_on
    @config.expects(:on).with(:after, :foo, "bing:blang", {:only => :bar, :zip => :zing})
    @config.after :bar, :foo, "bing:blang", :zip => :zing
  end

  def test_on_with_single_reference_should_add_task_callback
    @config.on :before, :a_test
    assert_equal 1, @config.callbacks[:before].length
    assert_equal :a_test, @config.callbacks[:before][0].source
    @config.expects(:find_and_execute_task).with(:a_test)
    @config.callbacks[:before][0].call
  end

  def test_on_with_multi_reference_should_add_all_as_task_callback
    @config.on :before, :first, :second, :third
    assert_equal 3, @config.callbacks[:before].length
    assert_equal %w(first second third), @config.callbacks[:before].map { |c| c.source.to_s }
  end

  def test_on_with_block_should_add_block_as_proc_callback
    called = false
    @config.on(:before) { called = true }
    assert_equal 1, @config.callbacks[:before].length
    assert_instance_of Proc, @config.callbacks[:before][0].source
    @config.callbacks[:before][0].call
    assert called
  end

  def test_on_with_single_only_should_set_only_as_string_array_on_all_references
    @config.on :before, :first, "second:third", :only => :primary
    assert_equal 2, @config.callbacks[:before].length
    assert @config.callbacks[:before].all? { |c| c.only == %w(primary) }
  end

  def test_on_with_multi_only_should_set_only_as_string_array_on_all_references
    @config.on :before, :first, "second:third", :only => [:primary, "other:one"]
    assert_equal 2, @config.callbacks[:before].length
    assert @config.callbacks[:before].all? { |c| c.only == %w(primary other:one) }
  end

  def test_on_with_single_except_should_set_except_as_string_array_on_all_references
    @config.on :before, :first, "second:third", :except => :primary
    assert_equal 2, @config.callbacks[:before].length
    assert @config.callbacks[:before].all? { |c| c.except == %w(primary) }
  end

  def test_on_with_multi_except_should_set_except_as_string_array_on_all_references
    @config.on :before, :first, "second:third", :except => [:primary, "other:one"]
    assert_equal 2, @config.callbacks[:before].length
    assert @config.callbacks[:before].all? { |c| c.except == %w(primary other:one) }
  end

  def test_on_with_only_and_block_should_set_only_as_string_array
    @config.on(:before, :only => :primary) { blah }
    assert_equal 1, @config.callbacks[:before].length
    assert_equal %w(primary), @config.callbacks[:before].first.only
  end

  def test_on_with_except_and_block_should_set_except_as_string_array
    @config.on(:before, :except => :primary) { blah }
    assert_equal 1, @config.callbacks[:before].length
    assert_equal %w(primary), @config.callbacks[:before].first.except
  end
  
  def test_on_without_tasks_or_block_should_raise_error
    assert_raises(ArgumentError) { @config.on(:before) }
  end

  def test_on_with_both_tasks_and_block_should_raise_error
    assert_raises(ArgumentError) { @config.on(:before, :first) { blah } }
  end

  def test_trigger_without_constraints_should_invoke_all_callbacks
    task = stub(:fully_qualified_name => "any:old:thing")
    @config.on(:before, :first, "second:third")
    @config.on(:after, :another, "and:another")
    @config.expects(:find_and_execute_task).with(:first)
    @config.expects(:find_and_execute_task).with("second:third")
    @config.expects(:find_and_execute_task).with(:another).never
    @config.expects(:find_and_execute_task).with("and:another").never
    @config.trigger(:before, task)
  end

  def test_trigger_with_only_constraint_should_invoke_only_matching_callbacks
    task = stub(:fully_qualified_name => "any:old:thing")
    @config.on(:before, :first)
    @config.on(:before, "second:third", :only => "any:old:thing")
    @config.on(:before, "this:too", :only => "any:other:thing")
    @config.on(:after, :another, "and:another")
    @config.expects(:find_and_execute_task).with(:first)
    @config.expects(:find_and_execute_task).with("second:third")
    @config.expects(:find_and_execute_task).with("this:too").never
    @config.expects(:find_and_execute_task).with(:another).never
    @config.expects(:find_and_execute_task).with("and:another").never
    @config.trigger(:before, task)
  end

  def test_trigger_with_except_constraint_should_invoke_anything_but_matching_callbacks
    task = stub(:fully_qualified_name => "any:old:thing")
    @config.on(:before, :first)
    @config.on(:before, "second:third", :except => "any:old:thing")
    @config.on(:before, "this:too", :except => "any:other:thing")
    @config.on(:after, :another, "and:another")
    @config.expects(:find_and_execute_task).with(:first)
    @config.expects(:find_and_execute_task).with("second:third").never
    @config.expects(:find_and_execute_task).with("this:too")
    @config.expects(:find_and_execute_task).with(:another).never
    @config.expects(:find_and_execute_task).with("and:another").never
    @config.trigger(:before, task)
  end

  def test_trigger_without_task_should_invoke_all_callbacks_for_that_event
    task = stub(:fully_qualified_name => "any:old:thing")
    @config.on(:before, :first)
    @config.on(:before, "second:third", :except => "any:old:thing")
    @config.on(:before, "this:too", :except => "any:other:thing")
    @config.on(:after, :another, "and:another")
    @config.expects(:find_and_execute_task).with(:first)
    @config.expects(:find_and_execute_task).with("second:third")
    @config.expects(:find_and_execute_task).with("this:too")
    @config.expects(:find_and_execute_task).with(:another).never
    @config.expects(:find_and_execute_task).with("and:another").never
    @config.trigger(:before)
  end

  def test_execute_task_without_named_hooks_should_just_call_task
    ns = stub("namespace", :default_task => nil, :name => "old", :fully_qualified_name => "any:old")
    task = stub(:fully_qualified_name => "any:old:thing", :name => "thing", :namespace => ns)

    ns.stubs(:search_task).returns(nil)

    @config.execute_task(task)
    assert_equal [task], @config.called
  end

  def test_execute_task_with_named_before_hook_should_call_named_before_hook
    ns = stub("namespace", :default_task => nil, :name => "old", :fully_qualified_name => "any:old")
    task = stub(:fully_qualified_name => "any:old:thing", :name => "thing", :namespace => ns)
    before_task = stub(:fully_qualified_name => "any:old:before_thing", :name => "before_thing", :namespace => ns)

    ns.stubs(:search_task).returns(nil)
    ns.expects(:search_task).with("before_thing").returns(before_task)

    @config.execute_task(task)
    assert_equal [before_task, task], @config.called
  end

  def test_execute_task_with_named_after_hook_should_call_named_after_hook
    ns = stub("namespace", :default_task => nil, :name => "old", :fully_qualified_name => "any:old")
    task = stub(:fully_qualified_name => "any:old:thing", :name => "thing", :namespace => ns)
    after_task = stub(:fully_qualified_name => "any:old:after_thing", :name => "after_thing", :namespace => ns)

    ns.stubs(:search_task).returns(nil)
    ns.expects(:search_task).with("after_thing").returns(after_task)

    @config.execute_task(task)
    assert_equal [task, after_task], @config.called
  end

  def test_execute_task_with_on_hooks_should_trigger_hooks_around_task
    ns = stub("namespace", :default_task => nil, :name => "old", :fully_qualified_name => "any:old")
    task = stub(:fully_qualified_name => "any:old:thing", :name => "thing", :namespace => ns)
    before_task = stub(:fully_qualified_name => "any:old:before_thing", :name => "before_thing", :namespace => ns)
    after_task = stub(:fully_qualified_name => "any:old:after_thing", :name => "after_thing", :namespace => ns)

    ns.stubs(:search_task).returns(nil)
    ns.expects(:search_task).with("before_thing").returns(before_task)
    ns.expects(:search_task).with("after_thing").returns(after_task)

    @config.before("any:old:thing", :first_this, :then_this)
    @config.after("any:old:thing", :and_then_this, :lastly_this)

    [:first_this, :then_this, :and_then_this, :lastly_this].each do |t|
      @config.expects(:find_and_execute_task).with(t)
    end

    @config.execute_task(task)
  end
end
