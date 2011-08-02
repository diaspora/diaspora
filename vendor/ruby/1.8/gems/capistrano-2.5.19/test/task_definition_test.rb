require "utils"
require 'capistrano/task_definition'

# Silences the wanrnings raised in the two deprecation tests
$VERBOSE = nil

class TaskDefinitionTest < Test::Unit::TestCase
  def setup
    @namespace = namespace
  end

  def test_fqn_at_top_level_should_be_task_name
    task = new_task(:testing)
    assert_equal "testing", task.fully_qualified_name
  end

  def test_fqn_in_namespace_should_include_namespace_fqn
    ns = namespace("outer:inner")
    task = new_task(:testing, ns)
    assert_equal "outer:inner:testing", task.fully_qualified_name
  end

  def test_fqn_at_top_level_when_default_should_be_default
    task = new_task(:default)
    assert_equal "default", task.fully_qualified_name
  end

  def test_deprecation_warning_on_method_name_beginning_with_before_underscore
    name = "before_test"
    Kernel.expects(:warn).with("[Deprecation Warning] Naming tasks with before_ and after_ is deprecated, please see the new before() and after() methods. (Offending task name was #{name})")
    new_task(name)
  end

  def test_deprecation_warning_on_method_name_beginning_with_after_underscore
    name = "after_test"
    Kernel.expects(:warn).with("[Deprecation Warning] Naming tasks with before_ and after_ is deprecated, please see the new before() and after() methods. (Offending task name was #{name})")
    new_task(name)
  end

  def test_fqn_in_namespace_when_default_should_be_namespace_fqn
    ns = namespace("outer:inner")
    task = new_task(:default, ns)
    ns.stubs(:default_task => task)
    assert_equal "outer:inner", task.fully_qualified_name
  end

  def test_task_should_require_block
    assert_raises(ArgumentError) do
      Capistrano::TaskDefinition.new(:testing, @namespace)
    end
  end

  def test_description_should_return_empty_string_if_not_given
    assert_equal "", new_task(:testing).description
  end

  def test_description_should_return_desc_attribute
    assert_equal "something", new_task(:testing, @namespace, :desc => "something").description
  end

  def test_description_should_strip_leading_and_trailing_whitespace
    assert_equal "something", new_task(:testing, @namespace, :desc => "   something   ").description
  end

  def test_description_should_normalize_newlines
    assert_equal "a\nb\nc", new_task(:testing, @namespace, :desc => "a\nb\r\nc").description
  end

  def test_description_should_detect_and_remove_indentation
    desc = <<-DESC
      Here is some indented text \
      and I want all of this to \
      run together on a single line, \
      without any extraneous spaces.

        additional indentation will
        be preserved.
    DESC

    task = new_task(:testing, @namespace, :desc => desc)
    assert_equal "Here is some indented text and I want all of this to run together on a single line, without any extraneous spaces.\n\n  additional indentation will\n  be preserved.", task.description
  end

  def test_description_munging_should_be_sensitive_to_code_blocks
    desc = <<-DESC
      Here is a line \
      wrapped      with spacing in it.

        foo         bar
        baz         bang
    DESC

    task = new_task(:testing, @namespace, :desc => desc)
    assert_equal "Here is a line wrapped with spacing in it.\n\n  foo         bar\n  baz         bang", task.description
  end

  def test_brief_description_should_return_first_sentence_in_description
    desc = "This is the task. It does all kinds of things."
    task = new_task(:testing, @namespace, :desc => desc)
    assert_equal "This is the task.", task.brief_description
  end

  def test_brief_description_should_truncate_if_length_given
    desc = "This is the task that does all kinds of things. And then some."
    task = new_task(:testing, @namespace, :desc => desc)
    assert_equal "This is the task ...", task.brief_description(20)
  end

  def test_brief_description_should_not_break_at_period_in_middle_of_sentence
    task = new_task(:testing, @namespace, :desc => "Take file.txt and copy it.")
    assert_equal "Take file.txt and copy it.", task.brief_description

    task = new_task(:testing, @namespace, :desc => "Take file.txt and copy it. Then do something else.")
    assert_equal "Take file.txt and copy it.", task.brief_description
  end
end