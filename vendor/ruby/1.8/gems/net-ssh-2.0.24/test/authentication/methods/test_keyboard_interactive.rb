require 'common'
require 'net/ssh/authentication/methods/keyboard_interactive'
require 'authentication/methods/common'

module Authentication; module Methods

  class TestKeyboardInteractive < Test::Unit::TestCase
    include Common

    USERAUTH_INFO_REQUEST  = 60
    USERAUTH_INFO_RESPONSE = 61

    def test_authenticate_should_be_false_when_server_does_not_support_this_method
      transport.expect do |t,packet|
        assert_equal USERAUTH_REQUEST, packet.type
        assert_equal "jamis", packet.read_string
        assert_equal "ssh-connection", packet.read_string
        assert_equal "keyboard-interactive", packet.read_string
        assert_equal "", packet.read_string # language tags
        assert_equal "", packet.read_string # submethods

        t.return(USERAUTH_FAILURE, :string, "password")
      end

      assert_equal false, subject.authenticate("ssh-connection", "jamis")
    end

    def test_authenticate_should_be_false_if_given_password_is_not_accepted
      transport.expect do |t,packet|
        assert_equal USERAUTH_REQUEST, packet.type
        t.return(USERAUTH_INFO_REQUEST, :string, "", :string, "", :string, "", :long, 1, :string, "Password:", :bool, false)
        t.expect do |t2,packet2|
          assert_equal USERAUTH_INFO_RESPONSE, packet2.type
          assert_equal 1, packet2.read_long
          assert_equal "the-password", packet2.read_string
          t2.return(USERAUTH_FAILURE, :string, "publickey")
        end
      end

      assert_equal false, subject.authenticate("ssh-connection", "jamis", "the-password")
    end

    def test_authenticate_should_be_true_if_given_password_is_accepted
      transport.expect do |t,packet|
        assert_equal USERAUTH_REQUEST, packet.type
        t.return(USERAUTH_INFO_REQUEST, :string, "", :string, "", :string, "", :long, 1, :string, "Password:", :bool, false)
        t.expect do |t2,packet2|
          assert_equal USERAUTH_INFO_RESPONSE, packet2.type
          t2.return(USERAUTH_SUCCESS)
        end
      end

      assert subject.authenticate("ssh-connection", "jamis", "the-password")
    end

    def test_authenticate_should_duplicate_password_as_needed_to_fill_request
      transport.expect do |t,packet|
        assert_equal USERAUTH_REQUEST, packet.type
        t.return(USERAUTH_INFO_REQUEST, :string, "", :string, "", :string, "", :long, 2, :string, "Password:", :bool, false, :string, "Again:", :bool, false)
        t.expect do |t2,packet2|
          assert_equal USERAUTH_INFO_RESPONSE, packet2.type
          assert_equal 2, packet2.read_long
          assert_equal "the-password", packet2.read_string
          assert_equal "the-password", packet2.read_string
          t2.return(USERAUTH_SUCCESS)
        end
      end

      assert subject.authenticate("ssh-connection", "jamis", "the-password")
    end

    def test_authenticate_should_prompt_for_input_when_password_is_not_given
      subject.expects(:prompt).with("Name:", true).returns("name")
      subject.expects(:prompt).with("Password:", false).returns("password")

      transport.expect do |t,packet|
        assert_equal USERAUTH_REQUEST, packet.type
        t.return(USERAUTH_INFO_REQUEST, :string, "", :string, "", :string, "", :long, 2, :string, "Name:", :bool, true, :string, "Password:", :bool, false)
        t.expect do |t2,packet2|
          assert_equal USERAUTH_INFO_RESPONSE, packet2.type
          assert_equal 2, packet2.read_long
          assert_equal "name", packet2.read_string
          assert_equal "password", packet2.read_string
          t2.return(USERAUTH_SUCCESS)
        end
      end

      assert subject.authenticate("ssh-connection", "jamis", nil)
    end

    private

      def subject(options={})
        @subject ||= Net::SSH::Authentication::Methods::KeyboardInteractive.new(session(options), options)
      end
  end

end; end