require "utils"
require 'capistrano/configuration/namespaces'

class ConfigurationNamespacesDSLTest < Test::Unit::TestCase
  class MockConfig
    attr_reader :original_initialize_called, :options

    def initialize
      @original_initialize_called = true
      @options = {}
    end

    include Capistrano::Configuration::Namespaces
  end

  def setup
    @config = MockConfig.new
  end

  def test_initialize_should_initialize_collections
    assert @config.original_initialize_called
    assert @config.tasks.empty?
    assert @config.namespaces.empty?
  end

  def test_unqualified_task_should_define_task_at_top_namespace
    assert !@config.tasks.key?(:testing)
    @config.task(:testing) { puts "something" }
    assert @config.tasks.key?(:testing)
  end

  def test_qualification_should_define_task_within_namespace
    @config.namespace(:testing) do
      task(:nested) { puts "nested" }
    end

    assert !@config.tasks.key?(:nested)
    assert @config.namespaces.key?(:testing)
    assert @config.namespaces[:testing].tasks.key?(:nested)
  end

  def test_namespace_within_namespace_should_define_task_within_nested_namespace
    @config.namespace :outer do
      namespace :inner do
        task :nested do
          puts "nested"
        end
      end
    end

    assert !@config.tasks.key?(:nested)
    assert @config.namespaces.key?(:outer)
    assert @config.namespaces[:outer].namespaces.key?(:inner)
    assert @config.namespaces[:outer].namespaces[:inner].tasks.key?(:nested)
  end

  def test_pending_desc_should_apply_only_to_immediately_subsequent_task
    @config.desc "A description"
    @config.task(:testing) { puts "foo" }
    @config.task(:another) { puts "bar" }
    assert_equal "A description", @config.tasks[:testing].desc
    assert_nil @config.tasks[:another].desc
  end

  def test_pending_desc_should_apply_only_to_next_task_in_any_namespace
    @config.desc "A description"
    @config.namespace(:outer) { task(:testing) { puts "foo" } }
    assert_equal "A description", @config.namespaces[:outer].tasks[:testing].desc
  end

  def test_defining_task_without_block_should_raise_error
    assert_raises(ArgumentError) do
      @config.task(:testing)
    end
  end

  def test_defining_task_that_shadows_existing_method_should_raise_error
    assert_raises(ArgumentError) do
      @config.task(:sprintf) { puts "foo" }
    end
  end

  def test_defining_task_that_shadows_existing_namespace_should_raise_error
    @config.namespace(:outer) {}
    assert_raises(ArgumentError) do
      @config.task(:outer) { puts "foo" }
    end
  end

  def test_defining_namespace_that_shadows_existing_method_should_raise_error
    assert_raises(ArgumentError) do
      @config.namespace(:sprintf) {}
    end
  end

  def test_defining_namespace_that_shadows_existing_task_should_raise_error
    @config.task(:testing) { puts "foo" }
    assert_raises(ArgumentError) do
      @config.namespace(:testing) {}
    end
  end

  def test_defining_task_that_shadows_existing_task_should_not_raise_error
    @config.task(:original) { puts "foo" }
    assert_nothing_raised do
      @config.task(:original) { puts "bar" }
    end
  end

  def test_defining_ask_should_add_task_as_method
    assert !@config.methods.any? { |m| m.to_sym == :original }
    @config.task(:original) { puts "foo" }
    assert @config.methods.any? { |m| m.to_sym == :original }
  end

  def test_calling_defined_task_should_delegate_to_execute_task
    @config.task(:original) { puts "foo" }
    @config.expects(:execute_task).with(@config.tasks[:original])
    @config.original
  end

  def test_role_inside_namespace_should_raise_error
    assert_raises(NotImplementedError) do
      @config.namespace(:outer) do
        role :app, "hello"
      end
    end
  end

  def test_name_for_top_level_should_be_nil
    assert_nil @config.name
  end

  def test_parent_for_top_level_should_be_nil
    assert_nil @config.parent
  end

  def test_fqn_for_top_level_should_be_nil
    assert_nil @config.fully_qualified_name
  end

  def test_fqn_for_namespace_should_be_the_name_of_the_namespace
    @config.namespace(:outer) {}
    assert_equal "outer", @config.namespaces[:outer].fully_qualified_name
  end

  def test_parent_for_namespace_should_be_the_top_level
    @config.namespace(:outer) {}
    assert_equal @config, @config.namespaces[:outer].parent    
  end

  def test_fqn_for_nested_namespace_should_be_color_delimited
    @config.namespace(:outer) { namespace(:inner) {} }
    assert_equal "outer:inner", @config.namespaces[:outer].namespaces[:inner].fully_qualified_name
  end

  def test_parent_for_nested_namespace_should_be_the_nesting_namespace
    @config.namespace(:outer) { namespace(:inner) {} }
    assert_equal @config.namespaces[:outer], @config.namespaces[:outer].namespaces[:inner].parent
  end

  def test_find_task_should_dereference_nested_tasks
    @config.namespace(:outer) do
      namespace(:inner) { task(:nested) { puts "nested" } }
    end

    task = @config.find_task("outer:inner:nested")
    assert_not_nil task
    assert_equal "outer:inner:nested", task.fully_qualified_name
  end

  def test_find_task_should_return_nil_if_no_task_matches
    assert_nil @config.find_task("outer:inner:nested")
  end

  def test_find_task_should_return_default_if_deferences_to_namespace_and_namespace_has_default
    @config.namespace(:outer) do
      namespace(:inner) { task(:default) { puts "nested" } }
    end

    task = @config.find_task("outer:inner")
    assert_not_nil task
    assert_equal :default, task.name
    assert_equal "outer:inner", task.namespace.fully_qualified_name
  end

  def test_find_task_should_return_nil_if_deferences_to_namespace_and_namespace_has_no_default
    @config.namespace(:outer) do
      namespace(:inner) { task(:nested) { puts "nested" } }
    end

    assert_nil @config.find_task("outer:inner")
  end

  def test_default_task_should_return_nil_for_top_level
    @config.task(:default) {}
    assert_nil @config.default_task
  end

  def test_default_task_should_return_nil_for_namespace_without_default
    @config.namespace(:outer) { task(:nested) { puts "nested" } }
    assert_nil @config.namespaces[:outer].default_task
  end

  def test_default_task_should_return_task_for_namespace_with_default
    @config.namespace(:outer) { task(:default) { puts "nested" } }
    task = @config.namespaces[:outer].default_task
    assert_not_nil task
    assert_equal :default, task.name
  end

  def test_task_list_should_return_only_tasks_immediately_within_namespace
    @config.task(:first) { puts "here" }
    @config.namespace(:outer) do
      task(:second) { puts "here" }
      namespace(:inner) do
        task(:third) { puts "here" }
      end
    end

    assert_equal %w(first), @config.task_list.map { |t| t.fully_qualified_name }
  end

  def test_task_list_with_all_should_return_all_tasks_under_this_namespace_recursively
    @config.task(:first) { puts "here" }
    @config.namespace(:outer) do
      task(:second) { puts "here" }
      namespace(:inner) do
        task(:third) { puts "here" }
      end
    end

    assert_equal %w(first outer:inner:third outer:second), @config.task_list(:all).map { |t| t.fully_qualified_name }.sort
  end

  def test_namespace_should_respond_to_its_parents_methods
    @config.namespace(:outer) {}
    ns = @config.namespaces[:outer]
    assert ns.respond_to?(:original_initialize_called)
  end
  
  def test_namespace_should_accept_respond_to_with_include_priv_parameter
    @config.namespace(:outer) {}
    ns = @config.namespaces[:outer]
    assert ns.respond_to?(:original_initialize_called, true)
  end

  def test_namespace_should_delegate_unknown_messages_to_its_parent
    @config.namespace(:outer) {}
    ns = @config.namespaces[:outer]
    assert ns.original_initialize_called
  end

  def test_namespace_should_not_understand_messages_that_neither_it_nor_its_parent_understands
    @config.namespace(:outer) {}
    ns = @config.namespaces[:outer]
    assert_raises(NoMethodError) { ns.alskdfjlsf }
  end

  def test_search_task_should_find_tasks_in_current_namespace
    @config.namespace(:outer) do
      namespace(:inner) do
        task(:third) { puts "here" }
      end
    end

    inner = @config.namespaces[:outer].namespaces[:inner]
    assert_equal inner.tasks[:third], inner.search_task(:third)
  end

  def test_search_task_should_find_tasks_in_parent_namespace
    @config.task(:first) { puts "here" }
    @config.namespace(:outer) do
      task(:second) { puts "here" }
      namespace(:inner) do
        task(:third) { puts "here" }
      end
    end

    inner = @config.namespaces[:outer].namespaces[:inner]
    assert_equal @config.tasks[:first], inner.search_task(:first)
  end

  def test_search_task_should_return_nil_if_no_tasks_are_found
    @config.namespace(:outer) { namespace(:inner) {} }
    inner = @config.namespaces[:outer].namespaces[:inner]
    assert_nil inner.search_task(:first)
  end

  def test_top_should_return_self_if_self_is_top
    assert_equal @config, @config.top
  end

  def test_top_should_return_parent_if_parent_is_top
    @config.namespace(:outer) {}
    assert_equal @config, @config.namespaces[:outer].top
  end

  def test_top_should_return_topmost_parent_if_self_is_deeply_nested
    @config.namespace(:outer) { namespace(:middle) { namespace(:inner) {} } }
    assert_equal @config, @config.namespaces[:outer].namespaces[:middle].namespaces[:inner].top
  end

  def test_find_task_should_return_nil_when_empty_inner_task
    @config.namespace :outer do
      namespace :inner do
      end
    end
    assert_nil @config.find_task("outer::inner")
  end
end