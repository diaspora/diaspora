require 'common'
require 'net/ssh/authentication/session'

module Authentication

  class TestSession < Test::Unit::TestCase
    include Net::SSH::Transport::Constants
    include Net::SSH::Authentication::Constants

    def test_constructor_should_set_defaults
      assert_equal %w(publickey hostbased password keyboard-interactive), session.auth_methods
      assert_equal session.auth_methods, session.allowed_auth_methods
    end

    def test_authenticate_should_raise_error_if_service_request_fails
      transport.expect do |t, packet|
        assert_equal SERVICE_REQUEST, packet.type
        assert_equal "ssh-userauth", packet.read_string
        t.return(255)
      end

      assert_raises(Net::SSH::Exception) { session.authenticate("next service", "username", "password") }
    end

    def test_authenticate_should_return_false_if_all_auth_methods_fail
      transport.expect do |t, packet|
        assert_equal SERVICE_REQUEST, packet.type
        assert_equal "ssh-userauth", packet.read_string
        t.return(SERVICE_ACCEPT)
      end

      Net::SSH::Authentication::Methods::Publickey.any_instance.expects(:authenticate).with("next service", "username", "password").returns(false)
      Net::SSH::Authentication::Methods::Hostbased.any_instance.expects(:authenticate).with("next service", "username", "password").returns(false)
      Net::SSH::Authentication::Methods::Password.any_instance.expects(:authenticate).with("next service", "username", "password").returns(false)
      Net::SSH::Authentication::Methods::KeyboardInteractive.any_instance.expects(:authenticate).with("next service", "username", "password").returns(false)

      assert_equal false, session.authenticate("next service", "username", "password")
    end

    def test_next_message_should_silently_handle_USERAUTH_BANNER_packets
      transport.return(USERAUTH_BANNER, :string, "Howdy, folks!")
      transport.return(SERVICE_ACCEPT)
      assert_equal SERVICE_ACCEPT, session.next_message.type
    end

    def test_next_message_should_understand_USERAUTH_FAILURE
      transport.return(USERAUTH_FAILURE, :string, "a,b,c", :bool, false)
      packet = session.next_message
      assert_equal USERAUTH_FAILURE, packet.type
      assert_equal %w(a b c), session.allowed_auth_methods
    end

    (60..79).each do |type|
      define_method("test_next_message_should_return_packets_of_type_#{type}") do
        transport.return(type)
        assert_equal type, session.next_message.type
      end
    end

    def test_next_message_should_understand_USERAUTH_SUCCESS
      transport.return(USERAUTH_SUCCESS)
      assert !transport.hints[:authenticated]
      assert_equal USERAUTH_SUCCESS, session.next_message.type
      assert transport.hints[:authenticated]
    end

    def test_next_message_should_raise_error_on_unrecognized_packet_types
      transport.return(1)
      assert_raises(Net::SSH::Exception) { session.next_message }
    end

    def test_expect_message_should_raise_exception_if_next_packet_is_not_expected_type
      transport.return(SERVICE_ACCEPT)
      assert_raises(Net::SSH::Exception) { session.expect_message(USERAUTH_BANNER) }
    end

    def test_expect_message_should_return_packet_if_next_packet_is_expected_type
      transport.return(SERVICE_ACCEPT)
      assert_equal SERVICE_ACCEPT, session.expect_message(SERVICE_ACCEPT).type
    end

    private

      def session(options={})
        @session ||= Net::SSH::Authentication::Session.new(transport(options), options)
      end

      def transport(options={})
        @transport ||= MockTransport.new(options)
      end
  end

end
