require File.expand_path('../../test_helper', __FILE__)
require "mocha/configuration"

class ConfigurationTest < Test::Unit::TestCase
  def test_allow_temporarily_changes_config_when_given_block
    Mocha::Configuration.warn_when(:stubbing_method_unnecessarily)
    yielded = false
    Mocha::Configuration.allow(:stubbing_method_unnecessarily) do
      yielded = true
      assert Mocha::Configuration.allow?(:stubbing_method_unnecessarily)
    end
    assert yielded
    assert Mocha::Configuration.warn_when?(:stubbing_method_unnecessarily)
  end

  def test_prevent_temporarily_changes_config_when_given_block
    Mocha::Configuration.allow(:stubbing_method_unnecessarily)
    yielded = false
    Mocha::Configuration.prevent(:stubbing_method_unnecessarily) do
      yielded = true
      assert Mocha::Configuration.prevent?(:stubbing_method_unnecessarily)
    end
    assert yielded
    assert Mocha::Configuration.allow?(:stubbing_method_unnecessarily)
  end

  def test_warn_when_temporarily_changes_config_when_given_block
    Mocha::Configuration.allow(:stubbing_method_unnecessarily)
    yielded = false
    Mocha::Configuration.warn_when(:stubbing_method_unnecessarily) do
      yielded = true
      assert Mocha::Configuration.warn_when?(:stubbing_method_unnecessarily)
    end
    assert yielded
    assert Mocha::Configuration.allow?(:stubbing_method_unnecessarily)
  end
end

