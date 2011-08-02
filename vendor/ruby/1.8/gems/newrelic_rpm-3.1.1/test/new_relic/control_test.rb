require File.expand_path(File.join(File.dirname(__FILE__),'/../test_helper'))
class NewRelic::ControlTest < Test::Unit::TestCase

  attr_reader :c

  def setup

    NewRelic::Agent.manual_start(:dispatcher_instance_id => 'test')
    @c =  NewRelic::Control.instance
    raise 'oh geez, wrong class' unless NewRelic::Control.instance.is_a?(::NewRelic::Control::Frameworks::Test)
  end
  def shutdown
    NewRelic::Agent.shutdown
  end

  def test_cert_file_path
    assert @c.cert_file_path
    assert_equal File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'cert', 'cacert.pem')), @c.cert_file_path
  end
  
  # This test does not actually use the ruby agent in any way - it's
  # testing that the CA file we ship actually validates our server's
  # certificate. It's used for customers who enable verify_certificate
  def test_cert_file
    require 'socket'
    require 'openssl'

    s   = TCPSocket.new 'collector.newrelic.com', 443
    ctx = OpenSSL::SSL::SSLContext.new
    ctx.ca_file = @c.cert_file_path
    ctx.verify_mode = OpenSSL::SSL::VERIFY_PEER
    s   = OpenSSL::SSL::SSLSocket.new s, ctx
    s.connect
    # should not raise an error
  end
  
  # see above, but for staging, as well. This allows us to test new
  # certificates in a non-customer-facing place before setting them
  # live.
  def test_staging_cert_file
    require 'socket'
    require 'openssl'

    s   = TCPSocket.new 'staging-collector.newrelic.com', 443
    ctx = OpenSSL::SSL::SSLContext.new
    ctx.ca_file = @c.cert_file_path
    ctx.verify_mode = OpenSSL::SSL::VERIFY_PEER
    s   = OpenSSL::SSL::SSLSocket.new s, ctx
    s.connect
    # should not raise an error
  end

  def test_monitor_mode
    assert ! @c.monitor_mode?
    @c.settings.delete 'enabled'
    @c.settings.delete 'monitor_mode'
    assert !@c.monitor_mode?
    @c['enabled'] = false
    assert ! @c.monitor_mode?
    @c['enabled'] = true
    assert @c.monitor_mode?
    @c['monitor_mode'] = nil
    assert !@c.monitor_mode?
    @c['monitor_mode'] = false
    assert !@c.monitor_mode?
    @c['monitor_mode'] = true
    assert @c.monitor_mode?
  ensure
    @c['enabled'] = false
    @c['monitor_mode'] = false
  end

  def test_test_config
    if defined?(Rails) && Rails::VERSION::MAJOR.to_i == 3
      assert_equal :rails3, c.app
    elsif defined?(Rails)
      assert_equal :rails, c.app
    else
      assert_equal :test, c.app
    end
    assert_equal :test, c.framework
    assert_match /test/i, c.dispatcher_instance_id
    assert("" == c.dispatcher.to_s, "Expected dispatcher to be empty, but was #{c.dispatcher.to_s}")
    assert !c['enabled']
    assert_equal false, c['monitor_mode']
    c.local_env
  end

  def test_root
    assert File.directory?(NewRelic::Control.newrelic_root), NewRelic::Control.newrelic_root
    if defined?(Rails)
      assert File.directory?(File.join(NewRelic::Control.newrelic_root, "lib")), NewRelic::Control.newrelic_root +  "/lib"
    end
  end

  def test_info
    props = NewRelic::Control.instance.local_env.snapshot
    if defined?(Rails)
      assert_match /jdbc|postgres|mysql|sqlite/, props.assoc('Database adapter').last, props.inspect
    end
  end

  def test_resolve_ip
    assert_equal nil, c.send(:convert_to_ip_address, 'localhost')
    assert_equal nil, c.send(:convert_to_ip_address, 'q1239988737.us')
    # This will fail if you don't have a valid, accessible, DNS server
    assert_equal '204.93.223.153', c.send(:convert_to_ip_address, 'collector.newrelic.com')
  end

  class FakeResolv
    def self.getaddress(host)
      raise 'deliberately broken'
    end
  end

  def test_resolve_ip_with_broken_dns
    # Here be dragons: disable the ruby DNS lookup methods we use so
    # that it will actually fail to resolve.
    old_resolv = Resolv
    old_ipsocket = IPSocket
    Object.instance_eval { remove_const :Resolv}
    Object.instance_eval {remove_const:'IPSocket' }
    assert_equal(nil, c.send(:convert_to_ip_address, 'collector.newrelic.com'), "DNS is down, should be no IP for server")

    Object.instance_eval {const_set('Resolv', old_resolv); const_set('IPSocket', old_ipsocket)}
    # these are here to make sure that the constant tomfoolery above
    # has not broket the system unduly
    assert_equal old_resolv, Resolv
    assert_equal old_ipsocket, IPSocket
  end



  def test_config_yaml_erb
    assert_equal 'heyheyhey', c['erb_value']
    assert_equal '', c['message']
    assert_equal '', c['license_key']
  end

  def test_appnames
    assert_equal %w[a b c], NewRelic::Control.instance.app_names
  end

  def test_config_booleans
    assert_equal c['tval'], true
    assert_equal c['fval'], false
    assert_nil c['not_in_yaml_val']
    assert_equal c['yval'], true
    assert_equal c['sval'], 'sure'
  end
  def test_config_apdex
    assert_equal 1.1, c.apdex_t
  end
#  def test_transaction_threshold
#    assert_equal 'Apdex_f', c['transaction_tracer']['transaction_threshold']
#    assert_equal 4.4, NewRelic::Agent::Agent.instance.instance_variable_get('@slowest_transaction_threshold')
#  end
  def test_log_file_name
    NewRelic::Control.instance.setup_log
    assert_match /newrelic_agent.log$/, c.instance_variable_get('@log_file')
  end

#  def test_transaction_threshold__apdex
#    forced_start
#    assert_equal 'Apdex_f', c['transaction_tracer']['transaction_threshold']
#    assert_equal 4.4, NewRelic::Agent::Agent.instance.instance_variable_get('@slowest_transaction_threshold')
#  end

  def test_transaction_threshold__default

    forced_start :transaction_tracer => { :transaction_threshold => nil}
    assert_nil c['transaction_tracer']['transaction_threshold']
    assert_equal 2.0, NewRelic::Agent::Agent.instance.instance_variable_get('@slowest_transaction_threshold')
  end

  def test_transaction_threshold__override
    forced_start :transaction_tracer => { :transaction_threshold => 1}
    assert_equal 1, c['transaction_tracer']['transaction_threshold']
    assert_equal 1, NewRelic::Agent::Agent.instance.instance_variable_get('@slowest_transaction_threshold')
  end
  def test_merging_options
    NewRelic::Control.send :public, :merge_options
    @c.merge_options :api_port => 66, :transaction_tracer => { :explain_threshold => 2.0 }
    assert_equal 66, NewRelic::Control.instance['api_port']
    assert_equal 2.0, NewRelic::Control.instance['transaction_tracer']['explain_threshold']
    assert_equal 'raw', NewRelic::Control.instance['transaction_tracer']['record_sql']
  end
  private
  def forced_start overrides = {}
    NewRelic::Agent.manual_start overrides
    # This is to force the agent to start again.
    NewRelic::Agent.instance.stubs(:started?).returns(nil)
    NewRelic::Agent.instance.start
  end
end
