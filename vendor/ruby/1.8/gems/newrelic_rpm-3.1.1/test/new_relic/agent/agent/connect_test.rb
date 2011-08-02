require File.expand_path(File.join(File.dirname(__FILE__),'..', '..', '..','test_helper'))
class NewRelic::Agent::Agent::ConnectTest < Test::Unit::TestCase
  require 'new_relic/agent/agent'
  include NewRelic::Agent::Agent::Connect

  def setup
    @connected = nil
    @keep_retrying = nil
    @connect_attempts = 1
    @connect_retry_period = 0
  end

  def test_tried_to_connect?
    # base case, should default to false
    assert !tried_to_connect?({})
  end

  def test_tried_to_connect_connected
    # is true if connected is true.
    @connected = true
    assert tried_to_connect?({})
  end

  def test_tried_to_connect_forced
    # is false if force_reconnect is true
    assert !tried_to_connect?({:force_reconnect => true})
  end

  def test_should_keep_retrying_base
    # default to true
    should_keep_retrying?({})
    assert @keep_retrying, "should keep retrying by default"
  end

  def test_should_keep_retrying_option_true
    # should be true if keep_retrying is true
    should_keep_retrying?({:keep_retrying => true})
  end

  def test_get_retry_period
    (1..6).each do |x|
      @connect_attempts = x
      assert_equal get_retry_period, x * 60, "should be #{x} minutes"
    end
    @connect_attempts = 100
    assert_equal get_retry_period, 600, "should max out at 10 minutes after 6 tries"
  end

  def test_increment_retry_period
    @connect_retry_period = 0
    @connect_attempts = 1
    assert_equal 0, connect_retry_period
    increment_retry_period!
    assert_equal 60, connect_retry_period
  end

  def test_should_retry_true
    @keep_retrying = true
    @connect_attempts = 1
    log.expects(:info).once
    self.expects(:increment_retry_period!).once
    assert should_retry?, "should retry in this circumstance"
    assert_equal 2, @connect_attempts, "should be on the second attempt"
  end

  def test_should_retry_false
    @keep_retrying = false
    self.expects(:disconnect).once
    assert !should_retry?
  end

  def test_disconnect
    assert disconnect
  end

  def test_attr_accessor_connect_retry_period
    assert_accessor(:connect_retry_period)
  end

  def test_attr_accessor_connect_attempts
    assert_accessor(:connect_attempts)
  end

  def test_log_error
    error = mock('error')
    error.expects(:backtrace).once.returns(["line", "secondline"])
    error.expects(:message).once.returns("message")
    fake_control = mock()
    fake_control.expects(:server).returns("server")
    self.expects(:control).once.returns(fake_control)
    log.expects(:error).with("Error establishing connection with New Relic Service at server: message")
    log.expects(:debug).with("line\nsecondline")
    log_error(error)
  end

  def test_handle_license_error
    error = mock('error')
    self.expects(:disconnect).once
    log.expects(:error).once.with("error message")
    log.expects(:info).once.with("Visit NewRelic.com to obtain a valid license key, or to upgrade your account.")
    error.expects(:message).returns("error message")
    handle_license_error(error)
  end

  def test_log_seed_token
    fake_control = mocked_control
    fake_control.expects(:validate_seed).times(2).returns("many seeds")
    fake_control.expects(:validate_token).once.returns("a token, man")
    log.expects(:debug).with("Connecting with validation seed/token: many seeds/a token, man").once
    log_seed_token
  end

  def test_no_seed_token
    fake_control = mocked_control
    fake_control.expects(:validate_seed).once.returns(nil)
    log.expects(:debug).never
    log_seed_token
  end

  def mocks_for_positive_environment_for_connect(value_for_control)
    control = mocked_control
    control.expects(:'[]').with('send_environment_info').once.returns(value_for_control)
    fake_env = mock('local_env')
    fake_env.expects(:snapshot).once.returns("snapshot")
    control.expects(:local_env).once.returns(fake_env)
  end

  def test_environment_for_connect_nil
    mocks_for_positive_environment_for_connect(nil)
    assert_equal 'snapshot', environment_for_connect
  end

  def test_environment_for_connect_positive
    mocks_for_positive_environment_for_connect(true)
    assert_equal 'snapshot', environment_for_connect
  end

  def test_environment_for_connect_negative
    control = mocked_control
    control.expects(:'[]').with('send_environment_info').once.returns(false)
    assert_equal [], environment_for_connect
  end

  def test_validate_settings
    control = mocked_control
    control.expects(:validate_seed).once
    control.expects(:validate_token).once
    assert_equal({:seed => nil, :token => nil}, validate_settings)
  end

  def test_connect_settings
    control = mocked_control
    control.expects(:app_names)
    control.expects(:settings)
    self.expects(:validate_settings)
    self.expects(:environment_for_connect)
    keys = %w(pid host app_name language agent_version environment settings validate)
    value = connect_settings
    keys.each do |k|
      assert(value.has_key?(k.to_sym), "should include the key #{k}")
    end
  end

  def test_configure_error_collector_base
    fake_collector = mocked_error_collector
    fake_collector.expects(:config_enabled).returns(false)
    fake_collector.expects(:enabled=).with(false)
    log.expects(:debug).with("Errors will not be sent to the New Relic service.")
    configure_error_collector!(false)
  end

  def test_configure_error_collector_enabled
    fake_collector = mocked_error_collector
    fake_collector.expects(:config_enabled).returns(true)
    fake_collector.expects(:enabled=).with(true)
    log.expects(:debug).with("Errors will be sent to the New Relic service.")
    configure_error_collector!(true)
  end

  def test_configure_error_collector_server_disabled
    fake_collector = mocked_error_collector
    fake_collector.expects(:config_enabled).returns(true)
    fake_collector.expects(:enabled=).with(false)
    log.expects(:debug).with("Errors will not be sent to the New Relic service.")
    configure_error_collector!(false)
  end

  def test_enable_random_samples
    sampling_rate = 10
    ts = @transaction_sampler = mock('ts')
    ts.expects(:random_sampling=).with(true)
    ts.expects(:sampling_rate=).with(sampling_rate)
    ts.expects(:sampling_rate).returns(sampling_rate)
    log.expects(:info).with("Transaction sampling enabled, rate = 10")
    enable_random_samples!(sampling_rate)
  end

  def test_enable_random_samples_with_no_sampling_rate
    # testing that we set a sane default for sampling rate
    sampling_rate = 0
    ts = @transaction_sampler = mock('ts')
    ts.expects(:random_sampling=).with(true)
    ts.expects(:sampling_rate=).with(10)
    ts.expects(:sampling_rate).returns(10)
    log.expects(:info).with("Transaction sampling enabled, rate = 10")
    enable_random_samples!(sampling_rate)
  end

  def test_configure_transaction_tracer_with_random_sampling
    @config_should_send_samples = true
    @should_send_random_samples = true
    @slowest_transaction_threshold = 5
    log.expects(:debug).with('Transaction tracing threshold is 5 seconds.')
    self.expects(:enable_random_samples!).with(10)
    configure_transaction_tracer!(true, 10)
    assert @should_send_samples
  end

  def test_configure_transaction_tracer_positive
    @config_should_send_samples = true
    @slowest_transaction_threshold = 5
    log.expects(:debug).with('Transaction tracing threshold is 5 seconds.')
    configure_transaction_tracer!(true, 10)
    assert @should_send_samples
  end

  def test_configure_transaction_tracer_negative
    @config_should_send_samples = false
    log.expects(:debug).with('Transaction traces will not be sent to the New Relic service.')
    configure_transaction_tracer!(true, 10)
    assert !@should_send_samples
  end

  def test_configure_transaction_tracer_server_disabled
    @config_should_send_samples = true
    log.expects(:debug).with('Transaction traces will not be sent to the New Relic service.')
    configure_transaction_tracer!(false, 10)
    assert !@should_send_samples
  end

  def test_set_collector_host_positive
    control = mocked_control
    self.expects(:invoke_remote).with(:get_redirect_host).returns('collector-deux.newrelic.com')
    control.expects(:server_from_host).with('collector-deux.newrelic.com').returns('correct')
    set_collector_host!
    assert_equal 'correct', @collector
  end

  def test_set_collector_host_negative
    @collector = 'initial value'
    control = mocked_control
    self.expects(:invoke_remote).with(:get_redirect_host).returns(nil)
    set_collector_host!
    assert_equal 'initial value', @collector, "should not modify collector value"
  end

  def test_configure_transaction_tracer_random_samples
    @config_should_send_samples = true
    @should_send_random_samples = true
    self.expects(:enable_random_samples!).with(10)
    log.expects(:debug)
    configure_transaction_tracer!(true, 10)
    assert @should_send_samples
  end

  def test_query_server_for_configuration
    self.expects(:set_collector_host!)
    self.expects(:connect_to_server).returns("so happy")
    self.expects(:finish_setup).with("so happy")
    query_server_for_configuration
  end

  def test_finish_setup
    config = {
      'agent_run_id' => 'fishsticks',
      'data_report_period' => 'pasta sauce',
      'url_rules' => 'tamales',
      'collect_traces' => true,
      'collect_errors' => true,
      'sample_rate' => 10
    }
    self.expects(:log_connection!).with(config)
    self.expects(:configure_transaction_tracer!).with(true, 10)
    self.expects(:configure_error_collector!).with(true)
    finish_setup(config)
    assert_equal 'fishsticks', @agent_id
    assert_equal 'pasta sauce', @report_period
    assert_equal 'tamales', @url_rules
  end

  private

  def mocked_control
    fake_control = mock('control')
    self.stubs(:control).returns(fake_control)
    fake_control
  end

  def mocked_error_collector
    fake_collector = mock('error collector')
    self.stubs(:error_collector).returns(fake_collector)
    fake_collector
  end

  def log
    @logger ||= Object.new
  end

  def assert_accessor(sym)
    var_name = "@#{sym}"
    instance_variable_set(var_name, 1)
    assert (self.send(sym) == 1)
    self.send(sym.to_s + '=', 10)
    assert (instance_variable_get(var_name) == 10)
  end
end
