require File.expand_path(File.join(File.dirname(__FILE__),'..','..','test_helper'))
require "new_relic/agent/beacon_configuration"
class NewRelic::Agent::BeaconConfigurationTest < Test::Unit::TestCase
  def test_initialize_basic
    connect_data = {}
    bc = NewRelic::Agent::BeaconConfiguration.new(connect_data)
    assert_equal true, bc.rum_enabled
    assert_equal '', bc.browser_timing_header
    %w[application_id browser_monitoring_key beacon].each do |method|
      value = bc.send(method.to_sym)
      assert_equal nil, value, "Expected #{method} to be nil, but was #{value.inspect}"
    end
  end

  def test_initialize_with_real_data
    connect_data = {'browser_key' => 'a browser monitoring key', 'application_id' => 'an application id', 'beacon' => 'a beacon', 'rum_enabled' => true}
    bc = NewRelic::Agent::BeaconConfiguration.new(connect_data)
    assert_equal(true, bc.rum_enabled)
    assert_equal('a browser monitoring key', bc.browser_monitoring_key)
    assert_equal('an application id', bc.application_id)
    assert_equal('a beacon', bc.beacon)
    assert_equal(109, bc.browser_timing_header.size, "should output the javascript with all the data available")
  end

  def test_license_bytes_nil
    connect_data = {}
    NewRelic::Control.instance.expects(:license_key).returns('a' * 40).once
    bc = NewRelic::Agent::BeaconConfiguration.new(connect_data)
    assert_equal([97] * 40, bc.license_bytes, 'should return the bytes of the license key')
  end

  def test_license_bytes_existing_bytes
    connect_data = {}
    bc = NewRelic::Agent::BeaconConfiguration.new(connect_data)
    bc.instance_eval { @license_bytes = [97] * 40 }
    NewRelic::Control.instance.expects(:license_key).never
    assert_equal([97] * 40, bc.license_bytes, "should return the cached value if it exists")
  end

  def test_license_bytes_should_set_instance_cache
    connect_data = {}
    bc = NewRelic::Agent::BeaconConfiguration.new(connect_data)
    NewRelic::Control.instance.expects(:license_key).returns('a' * 40)
    bc.instance_eval { @license_bytes = nil }
    bc.license_bytes
    assert_equal([97] * 40, bc.instance_variable_get('@license_bytes'), "should cache the license bytes for later")
  end

  def test_build_browser_timing_header_disabled
    connect_data = {}
    bc = NewRelic::Agent::BeaconConfiguration.new(connect_data)
    bc.instance_eval { @rum_enabled = false }
    assert_equal '', bc.build_browser_timing_header, "should not return a header when rum enabled is false"
  end

  def test_build_browser_timing_header_enabled_but_no_key
    connect_data = {}
    bc = NewRelic::Agent::BeaconConfiguration.new(connect_data)
    bc.instance_eval { @rum_enabled = true; @browser_monitoring_key = nil }
    assert_equal '', bc.build_browser_timing_header, "should not return a header when browser_monitoring_key is nil"
  end
  
  def test_build_browser_timing_header_enabled_with_key
    connect_data = {}
    bc = NewRelic::Agent::BeaconConfiguration.new(connect_data)
    bc.instance_eval { @browser_monitoring_key = 'a browser monitoring key' }
    assert(bc.build_browser_timing_header.include?('NREUMQ'), "header should be generated when rum is enabled and browser monitoring key is set")
  end

  def test_build_browser_timing_header_should_html_safe_header
    mock_javascript = mock('javascript')
    connect_data = {'browser_key' => 'a' * 40}
    bc = NewRelic::Agent::BeaconConfiguration.new(connect_data)
    assert_equal('a' * 40, bc.instance_variable_get('@browser_monitoring_key'), "should save the key from the config")
    bc.expects(:javascript_header).returns(mock_javascript)
    mock_javascript.expects(:respond_to?).with(:html_safe).returns(true)
    mock_javascript.expects(:html_safe)
    bc.build_browser_timing_header
  end
  
  def test_build_load_file_js_load_episodes_file_false
    connect_data = {'rum.load_episodes_file' => false}
    bc = NewRelic::Agent::BeaconConfiguration.new(connect_data)
    assert_equal(186, bc.build_load_file_js(connect_data).size,
                 "should include timing footer but not rum.js load")
  end
  
  def test_build_load_file_js_load_episodes_file_missing
    connect_data = {}
    bc = NewRelic::Agent::BeaconConfiguration.new(connect_data)
    assert_equal(304, bc.build_load_file_js(connect_data).size,
                 "should output the javascript when there is no configuration")
  end

  def test_build_load_file_js_load_episodes_file_present
    connect_data = {'rum.load_episodes_file' => true}
    bc = NewRelic::Agent::BeaconConfiguration.new(connect_data)
    assert_equal(304, bc.build_load_file_js(connect_data).size,
            "should output the javascript when rum.load_episodes_file is true")
  end
  
  def test_build_load_file_js_load_episodes_file_with_episodes_url
    connect_data = {'episodes_url' => 'an episodes url'}
    bc = NewRelic::Agent::BeaconConfiguration.new(connect_data)
    assert(bc.build_load_file_js(connect_data).include?('an episodes url'),
           "should include the episodes url by default")
  end
end
