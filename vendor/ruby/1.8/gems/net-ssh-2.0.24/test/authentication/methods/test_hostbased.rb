require 'common'
require 'net/ssh/authentication/methods/hostbased'
require 'authentication/methods/common'

module Authentication; module Methods

  class TestHostbased < Test::Unit::TestCase
    include Common

    def test_authenticate_should_return_false_when_no_key_manager_has_been_set
      assert_equal false, subject(:key_manager => nil).authenticate("ssh-connection", "jamis")
    end

    def test_authenticate_should_return_false_when_key_manager_has_no_keys
      assert_equal false, subject(:keys => []).authenticate("ssh-connection", "jamis")
    end

    def test_authenticate_should_return_false_if_no_keys_can_authenticate
      ENV.stubs(:[]).with('USER').returns(nil)
      key_manager.expects(:sign).with(&signature_parameters(keys.first)).returns("sig-one")
      key_manager.expects(:sign).with(&signature_parameters(keys.last)).returns("sig-two")

      transport.expect do |t, packet|
        assert_equal USERAUTH_REQUEST, packet.type
        assert verify_userauth_request_packet(packet, keys.first)
        assert_equal "sig-one", packet.read_string
        t.return(USERAUTH_FAILURE, :string, "hostbased,password")

        t.expect do |t2, packet2|
          assert_equal USERAUTH_REQUEST, packet2.type
          assert verify_userauth_request_packet(packet2, keys.last)
          assert_equal "sig-two", packet2.read_string
          t2.return(USERAUTH_FAILURE, :string, "hostbased,password")
        end
      end

      assert_equal false, subject.authenticate("ssh-connection", "jamis")
    end

    def test_authenticate_should_return_true_if_any_key_can_authenticate
      ENV.stubs(:[]).with('USER').returns(nil)
      key_manager.expects(:sign).with(&signature_parameters(keys.first)).returns("sig-one")

      transport.expect do |t, packet|
        assert_equal USERAUTH_REQUEST, packet.type
        assert verify_userauth_request_packet(packet, keys.first)
        assert_equal "sig-one", packet.read_string
        t.return(USERAUTH_SUCCESS)
      end

      assert subject.authenticate("ssh-connection", "jamis")
    end

    private

      def signature_parameters(key)
        Proc.new do |given_key, data|
          next false unless given_key.to_blob == key.to_blob
          buffer = Net::SSH::Buffer.new(data)
          buffer.read_string == "abcxyz123"      && # session-id
          buffer.read_byte   == USERAUTH_REQUEST && # type
          verify_userauth_request_packet(buffer, key)
        end
      end

      def verify_userauth_request_packet(packet, key)
        packet.read_string == "jamis"          && # user-name
        packet.read_string == "ssh-connection" && # next service
        packet.read_string == "hostbased"      && # auth-method
        packet.read_string == key.ssh_type     && # key type
        packet.read_buffer.read_key.to_blob == key.to_blob && # key
        packet.read_string == "me.ssh.test."   && # client hostname
        packet.read_string == "jamis"             # client username
      end

      @@keys = nil
      def keys
        @@keys ||= [OpenSSL::PKey::RSA.new(512), OpenSSL::PKey::DSA.new(512)]
      end

      def key_manager(options={})
        @key_manager ||= begin
          manager = stub("key_manager")
          manager.stubs(:each_identity).multiple_yields(*(options[:keys] || keys))
          manager
        end
      end

      def subject(options={})
        options[:key_manager] = key_manager(options) unless options.key?(:key_manager)
        @subject ||= Net::SSH::Authentication::Methods::Hostbased.new(session(options), options)
      end

      def socket(options={})
        @socket ||= stub("socket", :client_name => "me.ssh.test")
      end

      def transport(options={})
        @transport ||= MockTransport.new(options.merge(:socket => socket))
      end

      def session(options={})
        @session ||= begin
          sess = stub("auth-session", :logger => nil, :transport => transport(options))
          def sess.next_message
            transport.next_message
          end
          sess
        end
      end

  end

end; end
