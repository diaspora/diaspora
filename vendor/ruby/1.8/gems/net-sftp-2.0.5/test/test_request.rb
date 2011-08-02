require 'common'

class RequestTest < Net::SFTP::TestCase
  def test_property_setter_should_symbolize_key
    request = Net::SFTP::Request.new(stub("session"), :open, 1)
    request["key"] = :value
    assert_equal :value, request['key']
    assert_equal :value, request[:key]
    assert_equal :value, request.properties[:key]
    assert_nil request.properties['key']
  end

  def test_pending_should_query_pending_requests_of_session
    session = stub("session", :pending_requests => {1 => true})
    request = Net::SFTP::Request.new(session, :open, 1)
    assert request.pending?
    request = Net::SFTP::Request.new(session, :open, 2)
    assert !request.pending?
  end

  def test_wait_should_run_loop_while_pending_and_return_self
    session = MockSession.new
    request = Net::SFTP::Request.new(session, :open, 1)
    request.expects(:pending?).times(4).returns(true, true, true, false)
    assert_equal 0, session.loops
    assert_equal request, request.wait
    assert_equal 4, session.loops
  end

  def test_respond_to_should_set_response_property
    packet = stub("packet", :type => 1)
    session = stub("session", :protocol => mock("protocol"))
    session.protocol.expects(:parse).with(packet).returns({})
    request = Net::SFTP::Request.new(session, :open, 1)
    assert_nil request.response
    request.respond_to(packet)
    assert_instance_of Net::SFTP::Response, request.response
  end

  def test_respond_to_with_callback_should_invoke_callback
    packet = stub("packet", :type => 1)
    session = stub("session", :protocol => mock("protocol"))
    session.protocol.expects(:parse).with(packet).returns({})

    called = false
    request = Net::SFTP::Request.new(session, :open, 1) do |response|
      called = true
      assert_equal request.response, response
    end

    request.respond_to(packet)
    assert called
  end

  private

    class MockSession
      attr_reader :loops

      def initialize
        @loops = 0
      end

      def loop
        while true
          @loops += 1
          break unless yield
        end
      end
    end
end