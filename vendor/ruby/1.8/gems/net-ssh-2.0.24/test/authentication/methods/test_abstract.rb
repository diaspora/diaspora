require 'common'
require 'authentication/methods/common'
require 'net/ssh/authentication/methods/abstract'

module Authentication; module Methods

  class TestAbstract < Test::Unit::TestCase
    include Common

    def test_constructor_should_set_defaults
      assert_nil subject.key_manager
    end

    def test_constructor_should_honor_options
      assert_equal :manager, subject(:key_manager => :manager).key_manager
    end

    def test_session_id_should_query_session_id_from_key_exchange
      transport.stubs(:algorithms).returns(stub("algorithms", :session_id => "abcxyz123"))
      assert_equal "abcxyz123", subject.session_id
    end

    def test_send_message_should_delegate_to_transport
      transport.expects(:send_message).with("abcxyz123")
      subject.send_message("abcxyz123")
    end

    def test_userauth_request_should_build_well_formed_userauth_packet
      packet = subject.userauth_request("jamis", "ssh-connection", "password")
      assert_equal "\062\0\0\0\005jamis\0\0\0\016ssh-connection\0\0\0\010password", packet.to_s
    end

    def test_userauth_request_should_translate_extra_booleans_onto_end
      packet = subject.userauth_request("jamis", "ssh-connection", "password", true, false)
      assert_equal "\062\0\0\0\005jamis\0\0\0\016ssh-connection\0\0\0\010password\1\0", packet.to_s
    end

    def test_userauth_request_should_translate_extra_strings_onto_end
      packet = subject.userauth_request("jamis", "ssh-connection", "password", "foo", "bar")
      assert_equal "\062\0\0\0\005jamis\0\0\0\016ssh-connection\0\0\0\010password\0\0\0\3foo\0\0\0\3bar", packet.to_s
    end

    private

      def subject(options={})
        @subject ||= Net::SSH::Authentication::Methods::Abstract.new(session(options), options)
      end

  end

end; end