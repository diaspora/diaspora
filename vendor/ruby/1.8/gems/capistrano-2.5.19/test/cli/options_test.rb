require "utils"
require 'capistrano/cli/options'

class CLIOptionsTest < Test::Unit::TestCase
  class ExitException < Exception; end

  class MockCLI
    def initialize
      @args = []
    end

    attr_reader :args

    include Capistrano::CLI::Options
  end

  def setup
    @cli = MockCLI.new
  end

  def test_parse_options_should_require_non_empty_args_list
    @cli.stubs(:warn)
    @cli.expects(:exit).raises(ExitException)
    assert_raises(ExitException) { @cli.parse_options! }
  end
  
  def test_parse_options_with_d_should_set_debug_option
    @cli.args << "-d"
    @cli.parse_options!
    assert @cli.options[:debug]
  end

  def test_parse_options_with_n_should_set_dry_run_option
    @cli.args << "-n"
    @cli.parse_options!
    assert @cli.options[:dry_run]
  end

  def test_parse_options_with_dry_run_should_set_dry_run_option
    @cli.args << "--dry-run"
    @cli.parse_options!
    assert @cli.options[:dry_run]
  end

  def test_parse_options_with_e_should_set_explain_option
    @cli.args << "-e" << "sample"
    @cli.parse_options!
    assert_equal "sample", @cli.options[:explain]
  end

  def test_parse_options_with_f_should_add_recipe_file
    @cli.args << "-f" << "deploy"
    @cli.parse_options!
    assert_equal %w(deploy), @cli.options[:recipes]
  end

  def test_parse_options_with_multiple_f_should_add_each_as_recipe_file
    @cli.args << "-f" << "deploy" << "-f" << "monitor"
    @cli.parse_options!
    assert_equal %w(deploy monitor), @cli.options[:recipes]
  end

  def test_parse_options_with_H_should_show_verbose_help_and_exit
    @cli.expects(:exit).raises(ExitException)
    @cli.expects(:long_help)
    @cli.args << "-H"
    assert_raises(ExitException) { @cli.parse_options! }
  end

  def test_parse_options_with_h_should_show_options_and_exit
    @cli.expects(:puts).with(@cli.option_parser)
    @cli.expects(:exit).raises(ExitException)
    @cli.args << "-h"
    assert_raises(ExitException) { @cli.parse_options! }
  end

  def test_parse_options_with_p_should_prompt_for_password
    MockCLI.expects(:password_prompt).returns(:the_password)
    @cli.args << "-p"
    @cli.parse_options!
    assert_equal :the_password, @cli.options[:password]
  end

  def test_parse_options_without_p_should_set_proc_for_password
    @cli.args << "-e" << "sample"
    @cli.parse_options!
    assert_instance_of Proc, @cli.options[:password]
  end

  def test_parse_options_with_q_should_set_verbose_to_0
    @cli.args << "-q"
    @cli.parse_options!
    assert_equal 0, @cli.options[:verbose]
  end

  def test_parse_options_with_r_should_set_preserve_roles_option
    @cli.args << "-r"
    @cli.parse_options!
    assert @cli.options[:preserve_roles]
  end

  def test_parse_options_with_preserve_roles_should_set_preserve_roles_option
    @cli.args << "--preserve-roles"
    @cli.parse_options!
    assert @cli.options[:preserve_roles]
  end

  def test_parse_options_with_S_should_set_pre_vars
    @cli.args << "-S" << "foo=bar"
    @cli.parse_options!
    assert_equal "bar", @cli.options[:pre_vars][:foo]
  end

  def test_S_should_coerce_digits_to_integers
    @cli.args << "-S" << "foo=1234"
    @cli.parse_options!
    assert_equal 1234, @cli.options[:pre_vars][:foo]
  end

  def test_S_should_treat_quoted_integers_as_string
    @cli.args << "-S" << "foo=\"1234\""
    @cli.parse_options!
    assert_equal "1234", @cli.options[:pre_vars][:foo]
  end

  def test_S_should_treat_digits_with_dot_as_floating_point
    @cli.args << "-S" << "foo=3.1415"
    @cli.parse_options!
    assert_equal 3.1415, @cli.options[:pre_vars][:foo]
  end

  def test_S_should_treat_true_as_boolean_true
    @cli.args << "-S" << "foo=true"
    @cli.parse_options!
    assert_equal true, @cli.options[:pre_vars][:foo]
  end

  def test_S_should_treat_false_as_boolean_false
    @cli.args << "-S" << "foo=false"
    @cli.parse_options!
    assert_equal false, @cli.options[:pre_vars][:foo]
  end

  def test_S_should_treat_nil_as_nil
    @cli.args << "-S" << "foo=nil"
    @cli.parse_options!
    assert_equal nil, @cli.options[:pre_vars][:foo]
  end

  def test_parse_options_with_s_should_set_vars
    @cli.args << "-s" << "foo=bar"
    @cli.parse_options!
    assert_equal "bar", @cli.options[:vars][:foo]
  end

  def test_s_should_coerce_digits_to_integers
    @cli.args << "-s" << "foo=1234"
    @cli.parse_options!
    assert_equal 1234, @cli.options[:vars][:foo]
  end

  def test_s_should_treat_quoted_integers_as_string
    @cli.args << "-s" << "foo=\"1234\""
    @cli.parse_options!
    assert_equal "1234", @cli.options[:vars][:foo]
  end

  def test_s_should_treat_digits_with_dot_as_floating_point
    @cli.args << "-s" << "foo=3.1415"
    @cli.parse_options!
    assert_equal 3.1415, @cli.options[:vars][:foo]
  end

  def test_s_should_treat_true_as_boolean_true
    @cli.args << "-s" << "foo=true"
    @cli.parse_options!
    assert_equal true, @cli.options[:vars][:foo]
  end

  def test_s_should_treat_false_as_boolean_false
    @cli.args << "-s" << "foo=false"
    @cli.parse_options!
    assert_equal false, @cli.options[:vars][:foo]
  end

  def test_s_should_treat_nil_as_nil
    @cli.args << "-s" << "foo=nil"
    @cli.parse_options!
    assert_equal nil, @cli.options[:vars][:foo]
  end

  def test_parse_options_with_T_should_set_tasks_option_and_set_verbose_off
    @cli.args << "-T"
    @cli.parse_options!
    assert @cli.options[:tasks]
    assert_equal 0, @cli.options[:verbose]
  end

  def test_parse_options_with_V_should_show_version_and_exit
    @cli.args << "-V"
    @cli.expects(:puts).with { |s| s.include?(Capistrano::Version::STRING) }
    @cli.expects(:exit).raises(ExitException)
    assert_raises(ExitException) { @cli.parse_options! }
  end

  def test_parse_options_with_v_should_set_verbose_to_1
    @cli.args << "-v"
    @cli.parse_options!
    assert_equal 1, @cli.options[:verbose]
  end

  def test_parse_options_with_multiple_v_should_set_verbose_accordingly
    @cli.args << "-vvvvvvv"
    @cli.parse_options!
    assert_equal 7, @cli.options[:verbose]
  end

  def test_parse_options_without_X_should_set_sysconf
    @cli.args << "-v"
    @cli.parse_options!
    assert @cli.options.key?(:sysconf)
  end

  def test_parse_options_with_X_should_unset_sysconf
    @cli.args << "-X"
    @cli.parse_options!
    assert !@cli.options.key?(:sysconf)
  end

  def test_parse_options_without_x_should_set_dotfile
    @cli.args << "-v"
    @cli.parse_options!
    assert @cli.options.key?(:dotfile)
  end

  def test_parse_options_with_x_should_unset_dotfile
    @cli.args << "-x"
    @cli.parse_options!
    assert !@cli.options.key?(:dotfile)
  end

  def test_parse_options_without_q_or_v_should_set_verbose_to_3
    @cli.args << "-x"
    @cli.parse_options!
    assert_equal 3, @cli.options[:verbose]
  end

  def test_should_search_for_default_recipes_if_f_not_given
    @cli.expects(:look_for_default_recipe_file!)
    @cli.args << "-v"
    @cli.parse_options!
  end

  def test_should_not_search_for_default_recipes_if_f_given
    @cli.expects(:look_for_default_recipe_file!).never
    @cli.args << "-f" << "hello"
    @cli.parse_options!
  end

  def test_F_should_search_for_default_recipes_even_if_f_is_given
    @cli.expects(:look_for_default_recipe_file!)
    @cli.args << "-Ff" << "hello"
    @cli.parse_options!
  end

  def test_should_extract_env_vars_from_command_line
    assert_nil ENV["HELLO"]
    assert_nil ENV["ANOTHER"]

    @cli.args << "HELLO=world" << "hello" << "ANOTHER=value"
    @cli.parse_options!

    assert_equal "world", ENV["HELLO"]
    assert_equal "value", ENV["ANOTHER"]
  ensure
    ENV.delete("HELLO")
    ENV.delete("ANOTHER")
  end

  def test_remaining_args_should_be_added_to_actions_list
    @cli.args << "-v" << "HELLO=world" << "-f" << "foo" << "something" << "else"
    @cli.parse_options!
    assert_equal %w(something else), @cli.args
  ensure
    ENV.delete("HELLO")
  end

  def test_search_for_default_recipe_file_should_look_for_Capfile
    File.stubs(:file?).returns(false)
    File.expects(:file?).with("Capfile").returns(true)
    @cli.args << "-v"
    @cli.parse_options!
    assert_equal %w(Capfile), @cli.options[:recipes]
  end

  def test_search_for_default_recipe_file_should_look_for_capfile
    File.stubs(:file?).returns(false)
    File.expects(:file?).with("capfile").returns(true)
    @cli.args << "-v"
    @cli.parse_options!
    assert_equal %w(capfile), @cli.options[:recipes]
  end

  def test_search_for_default_recipe_should_hike_up_the_directory_tree_until_it_finds_default_recipe
    File.stubs(:file?).returns(false)
    File.expects(:file?).with("capfile").times(2).returns(false,true)
    Dir.expects(:pwd).times(3).returns(*%w(/bar/baz /bar/baz /bar))
    Dir.expects(:chdir).with("..")
    @cli.args << "-v"
    @cli.parse_options!
    assert_equal %w(capfile), @cli.options[:recipes]
  end

  def test_search_for_default_recipe_should_halt_at_root_directory
    File.stubs(:file?).returns(false)
    Dir.expects(:pwd).times(7).returns(*%w(/bar/baz /bar/baz /bar /bar / / /))
    Dir.expects(:chdir).with("..").times(3)
    Dir.expects(:chdir).with("/bar/baz")
    @cli.args << "-v"
    @cli.parse_options!
    assert @cli.options[:recipes].empty?
  end

  def test_parse_should_instantiate_new_cli_and_call_parse_options
    cli = mock("cli", :parse_options! => nil)
    MockCLI.expects(:new).with(%w(a b c)).returns(cli)
    assert_equal cli, MockCLI.parse(%w(a b c))
  end
end
