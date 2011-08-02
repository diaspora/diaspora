require 'test/unit'
require 'mocha'
require 'net/ssh/gateway'

class GatewayTest < Test::Unit::TestCase
  def teardown
    Thread.list { |t| t.kill unless Thread.current == t }
  end

  def test_shutdown_without_any_open_connections_should_terminate_session
    session, gateway = new_gateway
    session.expects(:close)
    gateway.shutdown!
    assert !gateway.active?
    assert session.forward.active_locals.empty?
  end

  def test_open_should_start_local_ports_at_65535
    gateway_session, gateway = new_gateway
    assert_equal 65535, gateway.open("app1", 22)
    assert_equal [65535, "app1", 22], gateway_session.forward.active_locals[65535]
  end

  def test_open_should_decrement_port_and_retry_if_ports_are_in_use
    gateway_session, gateway = new_gateway(:reserved => lambda { |n| n > 65000 })
    assert_equal 65000, gateway.open("app1", 22)
    assert_equal [65000, "app1", 22], gateway_session.forward.active_locals[65000]
  end

  def test_open_with_explicit_local_port_should_use_that_port
    gateway_session, gateway = new_gateway
    assert_equal 8181, gateway.open("app1", 22, 8181)
    assert_equal [8181, "app1", 22], gateway_session.forward.active_locals[8181]
  end

  def test_ssh_should_return_connection_when_no_block_is_given
    gateway_session, gateway = new_gateway
    expect_connect_to("127.0.0.1", "user", :port => 65535).returns(result = mock("session"))
    newsess = gateway.ssh("app1", "user")
    assert_equal result, newsess
    assert_equal [65535, "app1", 22], gateway_session.forward.active_locals[65535]
  end

  def test_ssh_with_block_should_yield_session_and_then_close_port
    gateway_session, gateway = new_gateway
    expect_connect_to("127.0.0.1", "user", :port => 65535).yields(result = mock("session"))
    yielded = false
    gateway.ssh("app1", "user") do |newsess|
      yielded = true
      assert_equal result, newsess
    end
    assert yielded
    assert gateway_session.forward.active_locals.empty?
  end

  def test_shutdown_should_cancel_active_forwarded_ports
    gateway_session, gateway = new_gateway
    gateway.open("app1", 80)
    assert !gateway_session.forward.active_locals.empty?
    gateway.shutdown!
    assert gateway_session.forward.active_locals.empty?
  end

  private

    def expect_connect_to(host, user, options={})
      Net::SSH.expects(:start).with do |real_host, real_user, real_options|
        host == real_host &&
        user == real_user &&
        options[:port] == real_options[:port]
      end
    end

    def new_gateway(options={})
      session = MockSession.new(options)
      expect_connect_to("test.host", "tester").returns(session)
      [session, Net::SSH::Gateway.new("test.host", "tester")]
    end

    class MockForward
      attr_reader :active_locals

      def initialize(options)
        @options = options
        @active_locals = {}
      end

      def cancel_local(port)
        @active_locals.delete(port)
      end

      def local(lport, host, rport)
        raise Errno::EADDRINUSE if @options[:reserved] && @options[:reserved][lport]
        @active_locals[lport] = [lport, host, rport]
      end
    end

    class MockSession
      attr_reader :forward

      def initialize(options={})
        @forward = MockForward.new(options)
      end

      def close
      end

      def process(wait=nil)
        true
      end

      def looping?
        @looping
      end

      def loop
        @looping = true
        sleep 0.1 while yield
        @looping = false
      end
    end
end
