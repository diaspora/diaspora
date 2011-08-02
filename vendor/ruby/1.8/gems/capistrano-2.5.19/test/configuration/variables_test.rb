require "utils"
require 'capistrano/configuration/variables'

class ConfigurationVariablesTest < Test::Unit::TestCase
  class MockConfig
    attr_reader :original_initialize_called

    def initialize
      @original_initialize_called = true
    end

    include Capistrano::Configuration::Variables
  end

  def setup
    MockConfig.any_instance.stubs(:logger).returns(stub_everything)
    @config = MockConfig.new
  end

  def test_initialize_should_initialize_variables_hash
    assert @config.original_initialize_called
    assert_equal({:ssh_options => {}, :logger => @config.logger}, @config.variables)
  end

  def test_set_should_add_variable_to_hash
    @config.set :sample, :value
    assert_equal :value, @config.variables[:sample]
  end

  def test_set_should_convert_variable_name_to_symbol
    @config.set "sample", :value
    assert_equal :value, @config.variables[:sample]
  end

  def test_set_should_be_aliased_to_square_brackets
    @config[:sample] = :value
    assert_equal :value, @config.variables[:sample]
  end

  def test_variables_should_be_accessible_as_read_accessors
    @config[:sample] = :value
    assert_equal :value, @config.sample
  end

  def test_method_missing_should_raise_error_if_no_variable_matches
    assert_raises(NoMethodError) do
      @config.sample
    end
  end

  def test_respond_to_should_look_for_variables
    assert !@config.respond_to?(:sample)
    @config[:sample] = :value
    assert @config.respond_to?(:sample)
  end
  
  def test_respond_to_with_include_priv_paramter
    assert !@config.respond_to?(:sample, true)
  end

  def test_set_should_require_value
    assert_raises(ArgumentError) do
      @config.set(:sample)
    end
  end

  def test_set_should_allow_value_to_be_omitted_if_block_is_given
    assert_nothing_raised do
      @config.set(:sample) { :value }
    end
    assert_instance_of Proc, @config.variables[:sample]
  end

  def test_set_should_not_allow_multiple_values
    assert_raises(ArgumentError) do
      @config.set(:sample, :value, :another)
    end
  end

  def test_set_should_not_allow_both_a_value_and_a_block
    assert_raises(ArgumentError) do
      @config.set(:sample, :value) { :block }
    end
  end

  def test_set_should_not_allow_capitalized_variables
    assert_raises(ArgumentError) do
      @config.set :Sample, :value
    end
  end

  def test_unset_should_remove_variable_from_hash
    @config.set :sample, :value
    assert @config.variables.key?(:sample)
    @config.unset :sample
    assert !@config.variables.key?(:sample)
  end

  def test_unset_should_clear_memory_of_original_proc
    @config.set(:sample) { :value }
    @config.fetch(:sample)
    @config.unset(:sample)
    assert_equal false, @config.reset!(:sample)
  end

  def test_exists_should_report_existance_of_variable_in_hash
    assert !@config.exists?(:sample)
    @config[:sample] = :value
    assert @config.exists?(:sample)
  end

  def test_reset_should_do_nothing_if_variable_does_not_exist
    assert_equal false, @config.reset!(:sample)
    assert !@config.variables.key?(:sample)
  end

  def test_reset_should_do_nothing_if_variable_is_not_a_proc
    @config.set(:sample, :value)
    assert_equal false, @config.reset!(:sample)
    assert_equal :value, @config.variables[:sample]
  end

  def test_reset_should_do_nothing_if_proc_variable_has_not_been_dereferenced
    @config.set(:sample) { :value }
    assert_equal false, @config.reset!(:sample)
    assert_instance_of Proc, @config.variables[:sample]
  end

  def test_reset_should_restore_variable_to_original_proc_value
    @config.set(:sample) { :value }
    assert_instance_of Proc, @config.variables[:sample]
    @config.fetch(:sample)
    assert_instance_of Symbol, @config.variables[:sample]
    assert @config.reset!(:sample)
    assert_instance_of Proc, @config.variables[:sample]
  end

  def test_fetch_should_return_stored_non_proc_value
    @config.set(:sample, :value)
    assert_equal :value, @config.fetch(:sample)
  end

  def test_fetch_should_raise_index_error_if_variable_does_not_exist
    assert_raises(IndexError) do
      @config.fetch(:sample)
    end
  end

  def test_fetch_should_return_default_if_variable_does_not_exist_and_default_is_given
    assert_nothing_raised do
      assert_equal :default_value, @config.fetch(:sample, :default_value)
    end
  end

  def test_fetch_should_invoke_block_if_variable_does_not_exist_and_block_is_given
    assert_nothing_raised do
      assert_equal :default_value, @config.fetch(:sample) { :default_value }
    end
  end

  def test_fetch_should_raise_argument_error_if_both_default_and_block_are_given
    assert_raises(ArgumentError) do
      @config.fetch(:sample, :default1) { :default2 }
    end
  end

  def test_fetch_should_dereference_proc_values
    @config.set(:sample) { :value }
    assert_instance_of Proc, @config.variables[:sample]
    assert_equal :value, @config.fetch(:sample)
    assert_instance_of Symbol, @config.variables[:sample]
  end

  def test_square_brackets_should_alias_fetch
    @config.set(:sample, :value)
    assert_equal :value, @config[:sample]
  end

  def test_square_brackets_should_return_nil_for_non_existant_variable
    assert_nothing_raised do
      assert_nil @config[:sample]
    end
  end
end