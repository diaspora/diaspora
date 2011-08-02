require File.expand_path(File.join(File.dirname(__FILE__),'/../../test_helper'))
class NewRelic::Control::ConfigurationTest < Test::Unit::TestCase
  require 'new_relic/control/configuration'
  include NewRelic::Control::Configuration
  
  def setup
    # The log stuff is memoized so let's clear it each time.
    NewRelic::Control.instance.instance_variable_set '@log_path', nil
    NewRelic::Control.instance.instance_variable_set '@log_file', nil
    @root = ::Rails::VERSION::MAJOR == 3 ? Rails.root : RAILS_ROOT
  end
  
  def teardown
    NewRelic::Control.instance.settings.delete 'log_file_path'
  end
  
  def test_license_key_defaults_to_env_variable
    ENV['NEWRELIC_LICENSE_KEY'] = nil
    self.expects(:fetch).with('license_key', nil)
    license_key

    ENV['NEWRELIC_LICENSE_KEY'] = "a string"
    self.expects(:fetch).with('license_key', 'a string')
    license_key
  end
  
  def test_log_path_uses_default_if_not_set
    NewRelic::Control.instance.setup_log
    assert_equal(File.expand_path("log/newrelic_agent.log"),
                 NewRelic::Control.instance.log_file)
  end

  def test_log_file_path_uses_given_value
    Dir.stubs(:mkdir).returns(true)
    NewRelic::Control.instance['log_file_path'] = 'lerg'
    NewRelic::Control.instance.setup_log
    assert_match(/\/lerg\/newrelic_agent.log/,
                 NewRelic::Control.instance.log_file)
  end
end
