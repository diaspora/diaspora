require 'common'
require 'net/ssh/transport/kex/diffie_hellman_group1_sha1'
require 'ostruct'

module Transport; module Kex

  class TestDiffieHellmanGroup1SHA1 < Test::Unit::TestCase
    include Net::SSH::Transport::Constants

    def setup
      @dh_options = @dh = @algorithms = @connection = @server_key = 
        @packet_data = @shared_secret = nil
    end

    def test_exchange_keys_should_return_expected_results_when_successful
      result = exchange!
      assert_equal session_id, result[:session_id]
      assert_equal server_key.to_blob, result[:server_key].to_blob
      assert_equal shared_secret, result[:shared_secret]
      assert_equal OpenSSL::Digest::SHA1, result[:hashing_algorithm]
    end

    def test_exchange_keys_with_unverifiable_host_should_raise_exception
      connection.verifier { false }
      assert_raises(Net::SSH::Exception) { exchange! }
    end

    def test_exchange_keys_with_signature_key_type_mismatch_should_raise_exception
      assert_raises(Net::SSH::Exception) { exchange! :key_type => "ssh-dss" }
    end

    def test_exchange_keys_with_host_key_type_mismatch_should_raise_exception
      algorithms :host_key => "ssh-dss"
      assert_raises(Net::SSH::Exception) { exchange! :key_type => "ssh-dss" }
    end

    def test_exchange_keys_when_server_signature_could_not_be_verified_should_raise_exception
      @signature = "1234567890"
      assert_raises(Net::SSH::Exception) { exchange! }
    end

    def test_exchange_keys_should_pass_expected_parameters_to_host_key_verifier
      verified = false
      connection.verifier do |data|
        verified = true
        assert_equal server_key.to_blob, data[:key].to_blob

        blob = b(:key, data[:key]).to_s
        fingerprint = OpenSSL::Digest::MD5.hexdigest(blob).scan(/../).join(":")

        assert_equal blob, data[:key_blob]
        assert_equal fingerprint, data[:fingerprint]
        assert_equal connection, data[:session]

        true
      end

      assert_nothing_raised { exchange! }
      assert verified
    end

    private

      def exchange!(options={})
        connection.expect do |t, buffer|
          assert_equal KEXDH_INIT, buffer.type
          assert_equal dh.dh.pub_key, buffer.read_bignum
          t.return(KEXDH_REPLY, :string, b(:key, server_key), :bignum, server_dh_pubkey, :string, b(:string, options[:key_type] || "ssh-rsa", :string, signature))
          connection.expect do |t2, buffer2|
            assert_equal NEWKEYS, buffer2.type
            t2.return(NEWKEYS)
          end
        end

        dh.exchange_keys
      end

      def dh_options(options={})
        @dh_options = options
      end

      def dh
        @dh ||= subject.new(algorithms, connection, packet_data.merge(:need_bytes => 20).merge(@dh_options || {}))
      end

      def algorithms(options={})
        @algorithms ||= OpenStruct.new(:host_key => options[:host_key] || "ssh-rsa")
      end

      def connection
        @connection ||= MockTransport.new
      end

      def subject
        Net::SSH::Transport::Kex::DiffieHellmanGroup1SHA1
      end

      # 512 bits is the smallest possible key that will work with this, so
      # we use it for speed reasons
      def server_key(bits=512)
        @server_key ||= OpenSSL::PKey::RSA.new(bits)
      end

      def packet_data
        @packet_data ||= { :client_version_string => "client version string",
          :server_version_string => "server version string",
          :server_algorithm_packet => "server algorithm packet",
          :client_algorithm_packet => "client algorithm packet" }
      end

      def server_dh_pubkey
        @server_dh_pubkey ||= bn(1234567890)
      end

      def shared_secret
        @shared_secret ||= OpenSSL::BN.new(dh.dh.compute_key(server_dh_pubkey), 2)
      end

      def session_id
        @session_id ||= begin
          buffer = Net::SSH::Buffer.from(:string, packet_data[:client_version_string],
            :string, packet_data[:server_version_string],
            :string, packet_data[:client_algorithm_packet],
            :string, packet_data[:server_algorithm_packet],
            :string, Net::SSH::Buffer.from(:key, server_key),
            :bignum, dh.dh.pub_key,
            :bignum, server_dh_pubkey,
            :bignum, shared_secret)
          OpenSSL::Digest::SHA1.digest(buffer.to_s)
        end
      end

      def signature
        @signature ||= server_key.ssh_do_sign(session_id)
      end

      def bn(number, base=10)
        OpenSSL::BN.new(number.to_s, base)
      end

      def b(*args)
        Net::SSH::Buffer.from(*args)
      end
  end

end; end