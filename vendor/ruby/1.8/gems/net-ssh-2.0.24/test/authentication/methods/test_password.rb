require 'common'
require 'net/ssh/authentication/methods/password'
require 'authentication/methods/common'

module Authentication; module Methods

  class TestPassword < Test::Unit::TestCase
    include Common

    def test_authenticate_when_password_is_unacceptible_should_return_false
      transport.expect do |t,packet|
        assert_equal USERAUTH_REQUEST, packet.type
        assert_equal "jamis", packet.read_string
        assert_equal "ssh-connection", packet.read_string
        assert_equal "password", packet.read_string
        assert_equal false, packet.read_bool
        assert_equal "the-password", packet.read_string

        t.return(USERAUTH_FAILURE, :string, "publickey")
      end

      assert !subject.authenticate("ssh-connection", "jamis", "the-password")
    end

    def test_authenticate_when_password_is_acceptible_should_return_true
      transport.expect do |t,packet|
        assert_equal USERAUTH_REQUEST, packet.type
        t.return(USERAUTH_SUCCESS)
      end

      assert subject.authenticate("ssh-connection", "jamis", "the-password")
    end

    def test_authenticate_should_return_false_if_password_change_request_is_received
      transport.expect do |t,packet|
        assert_equal USERAUTH_REQUEST, packet.type
        t.return(USERAUTH_PASSWD_CHANGEREQ, :string, "Change your password:", :string, "")
      end

      assert !subject.authenticate("ssh-connection", "jamis", "the-password")
    end

    private

      def subject(options={})
        @subject ||= Net::SSH::Authentication::Methods::Password.new(session(options), options)
      end
  end

end; end
