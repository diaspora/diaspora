require 'common'
require 'net/ssh/transport/algorithms'

module Transport

  class TestAlgorithms < Test::Unit::TestCase
    include Net::SSH::Transport::Constants

    def test_allowed_packets
      (0..255).each do |type|
        packet = stub("packet", :type => type)
        case type
        when 1..4, 6..19, 21..49 then assert(Net::SSH::Transport::Algorithms.allowed_packet?(packet), "#{type} should be allowed during key exchange")
        else assert(!Net::SSH::Transport::Algorithms.allowed_packet?(packet), "#{type} should not be allowed during key exchange")
        end
      end
    end

    def test_constructor_should_build_default_list_of_preferred_algorithms
      assert_equal %w(ssh-rsa ssh-dss), algorithms[:host_key]
      assert_equal %w(diffie-hellman-group-exchange-sha1 diffie-hellman-group1-sha1), algorithms[:kex]
      assert_equal %w(aes128-cbc 3des-cbc blowfish-cbc cast128-cbc aes192-cbc aes256-cbc rijndael-cbc@lysator.liu.se idea-cbc none arcfour128 arcfour256), algorithms[:encryption]
      assert_equal %w(hmac-sha1 hmac-md5 hmac-sha1-96 hmac-md5-96 none), algorithms[:hmac]
      assert_equal %w(none zlib@openssh.com zlib), algorithms[:compression]
      assert_equal %w(), algorithms[:language]
    end

    def test_constructor_should_set_client_and_server_prefs_identically
      %w(encryption hmac compression language).each do |key|
        assert_equal algorithms[key.to_sym], algorithms[:"#{key}_client"], key
        assert_equal algorithms[key.to_sym], algorithms[:"#{key}_server"], key
      end
    end

    def test_constructor_with_preferred_host_key_type_should_put_preferred_host_key_type_first
      assert_equal %w(ssh-dss ssh-rsa), algorithms(:host_key => "ssh-dss")[:host_key]
    end

    def test_constructor_with_known_hosts_reporting_known_host_key_should_use_that_host_key_type
      Net::SSH::KnownHosts.expects(:search_for).with("net.ssh.test,127.0.0.1", {}).returns([stub("key", :ssh_type => "ssh-dss")])
      assert_equal %w(ssh-dss ssh-rsa), algorithms[:host_key]
    end

    def test_constructor_with_unrecognized_host_key_type_should_raise_exception
      assert_raises(NotImplementedError) { algorithms(:host_key => "bogus") }
    end

    def test_constructor_with_preferred_kex_should_put_preferred_kex_first
      assert_equal %w(diffie-hellman-group1-sha1 diffie-hellman-group-exchange-sha1), algorithms(:kex => "diffie-hellman-group1-sha1")[:kex]
    end

    def test_constructor_with_unrecognized_kex_should_raise_exception
      assert_raises(NotImplementedError) { algorithms(:kex => "bogus") }
    end

    def test_constructor_with_preferred_encryption_should_put_preferred_encryption_first
      assert_equal %w(aes256-cbc aes128-cbc 3des-cbc blowfish-cbc cast128-cbc aes192-cbc rijndael-cbc@lysator.liu.se idea-cbc none arcfour128 arcfour256), algorithms(:encryption => "aes256-cbc")[:encryption]
    end

    def test_constructor_with_multiple_preferred_encryption_should_put_all_preferred_encryption_first
      assert_equal %w(aes256-cbc 3des-cbc idea-cbc aes128-cbc blowfish-cbc cast128-cbc aes192-cbc rijndael-cbc@lysator.liu.se none arcfour128 arcfour256), algorithms(:encryption => %w(aes256-cbc 3des-cbc idea-cbc))[:encryption]
    end

    def test_constructor_with_unrecognized_encryption_should_raise_exception
      assert_raises(NotImplementedError) { algorithms(:encryption => "bogus") }
    end

    def test_constructor_with_preferred_hmac_should_put_preferred_hmac_first
      assert_equal %w(hmac-md5-96 hmac-sha1 hmac-md5 hmac-sha1-96 none), algorithms(:hmac => "hmac-md5-96")[:hmac]
    end

    def test_constructor_with_multiple_preferred_hmac_should_put_all_preferred_hmac_first
      assert_equal %w(hmac-md5-96 hmac-sha1-96 hmac-sha1 hmac-md5 none), algorithms(:hmac => %w(hmac-md5-96 hmac-sha1-96))[:hmac]
    end

    def test_constructor_with_unrecognized_hmac_should_raise_exception
      assert_raises(NotImplementedError) { algorithms(:hmac => "bogus") }
    end

    def test_constructor_with_preferred_compression_should_put_preferred_compression_first
      assert_equal %w(zlib none zlib@openssh.com), algorithms(:compression => "zlib")[:compression]
    end

    def test_constructor_with_multiple_preferred_compression_should_put_all_preferred_compression_first
      assert_equal %w(zlib@openssh.com zlib none), algorithms(:compression => %w(zlib@openssh.com zlib))[:compression]
    end

    def test_constructor_with_general_preferred_compression_should_put_none_last
      assert_equal %w(zlib@openssh.com zlib none), algorithms(:compression => true)[:compression]
    end

    def test_constructor_with_unrecognized_compression_should_raise_exception
      assert_raises(NotImplementedError) { algorithms(:compression => "bogus") }
    end

    def test_initial_state_should_be_neither_pending_nor_initialized
      assert !algorithms.pending?
      assert !algorithms.initialized?
    end

    def test_key_exchange_when_initiated_by_server
      transport.expect do |t, buffer|
        assert_kexinit(buffer)
        install_mock_key_exchange(buffer)
      end

      install_mock_algorithm_lookups
      algorithms.accept_kexinit(kexinit)

      assert_exchange_results
    end

    def test_key_exchange_when_initiated_by_client
      state = nil
      transport.expect do |t, buffer|
        assert_kexinit(buffer)
        state = :sent_kexinit
        install_mock_key_exchange(buffer)
      end

      algorithms.rekey!
      assert_equal state, :sent_kexinit
      assert algorithms.pending?

      install_mock_algorithm_lookups
      algorithms.accept_kexinit(kexinit)

      assert_exchange_results
    end

    def test_key_exchange_when_server_does_not_support_preferred_kex_should_fallback_to_secondary
      kexinit :kex => "diffie-hellman-group1-sha1"
      transport.expect do |t,buffer|
        assert_kexinit(buffer)
        install_mock_key_exchange(buffer, :kex => Net::SSH::Transport::Kex::DiffieHellmanGroup1SHA1)
      end
      algorithms.accept_kexinit(kexinit)
    end

    def test_key_exchange_when_server_does_not_support_any_preferred_kex_should_raise_error
      kexinit :kex => "something-obscure"
      transport.expect { |t,buffer| assert_kexinit(buffer) }
      assert_raises(Net::SSH::Exception) { algorithms.accept_kexinit(kexinit) }
    end

    def test_allow_when_not_pending_should_be_true_for_all_packets
      (0..255).each do |type|
        packet = stub("packet", :type => type)
        assert algorithms.allow?(packet), type
      end
    end

    def test_allow_when_pending_should_be_true_only_for_packets_valid_during_key_exchange
      transport.expect!
      algorithms.rekey!
      assert algorithms.pending?

      (0..255).each do |type|
        packet = stub("packet", :type => type)
        case type
        when 1..4, 6..19, 21..49 then assert(algorithms.allow?(packet), "#{type} should be allowed during key exchange")
        else assert(!algorithms.allow?(packet), "#{type} should not be allowed during key exchange")
        end
      end
    end

    def test_exchange_with_zlib_compression_enabled_sets_compression_to_standard
      algorithms :compression => "zlib"

      transport.expect do |t, buffer|
        assert_kexinit(buffer, :compression_client => "zlib,none,zlib@openssh.com", :compression_server => "zlib,none,zlib@openssh.com")
        install_mock_key_exchange(buffer)
      end

      install_mock_algorithm_lookups
      algorithms.accept_kexinit(kexinit)

      assert_equal :standard, transport.client_options[:compression]
      assert_equal :standard, transport.server_options[:compression]
    end

    def test_exchange_with_zlib_at_openssh_dot_com_compression_enabled_sets_compression_to_delayed
      algorithms :compression => "zlib@openssh.com"

      transport.expect do |t, buffer|
        assert_kexinit(buffer, :compression_client => "zlib@openssh.com,none,zlib", :compression_server => "zlib@openssh.com,none,zlib")
        install_mock_key_exchange(buffer)
      end

      install_mock_algorithm_lookups
      algorithms.accept_kexinit(kexinit)

      assert_equal :delayed, transport.client_options[:compression]
      assert_equal :delayed, transport.server_options[:compression]
    end

    private

      def install_mock_key_exchange(buffer, options={})
        kex = options[:kex] || Net::SSH::Transport::Kex::DiffieHellmanGroupExchangeSHA1

        Net::SSH::Transport::Kex::MAP.each do |name, klass|
          next if klass == kex
          klass.expects(:new).never
        end

        kex.expects(:new).
          with(algorithms, transport,
            :client_version_string => Net::SSH::Transport::ServerVersion::PROTO_VERSION,
            :server_version_string => transport.server_version.version,
            :server_algorithm_packet => kexinit.to_s,
            :client_algorithm_packet => buffer.to_s,
            :need_bytes => 20,
            :logger => nil).
          returns(stub("kex", :exchange_keys => { :shared_secret => shared_secret, :session_id => session_id, :hashing_algorithm => hashing_algorithm }))
      end

      def install_mock_algorithm_lookups(options={})
        Net::SSH::Transport::CipherFactory.expects(:get).
          with(options[:client_cipher] || "aes128-cbc", :iv => key("A"), :key => key("C"), :shared => shared_secret.to_ssh, :hash => session_id, :digester => hashing_algorithm, :encrypt => true).
          returns(:client_cipher)
        Net::SSH::Transport::CipherFactory.expects(:get).
          with(options[:server_cipher] || "aes128-cbc", :iv => key("B"), :key => key("D"), :shared => shared_secret.to_ssh, :hash => session_id, :digester => hashing_algorithm, :decrypt => true).
          returns(:server_cipher)

        Net::SSH::Transport::HMAC.expects(:get).with(options[:client_hmac] || "hmac-sha1", key("E")).returns(:client_hmac)
        Net::SSH::Transport::HMAC.expects(:get).with(options[:server_hmac] || "hmac-sha1", key("F")).returns(:server_hmac)
      end

      def shared_secret
        @shared_secret ||= OpenSSL::BN.new("1234567890", 10)
      end

      def session_id
        @session_id ||= "this is the session id"
      end

      def hashing_algorithm
        OpenSSL::Digest::SHA1
      end

      def key(salt)
        hashing_algorithm.digest(shared_secret.to_ssh + session_id + salt + session_id)
      end

      def cipher(type, options={})
        Net::SSH::Transport::CipherFactory.get(type, options)
      end

      def kexinit(options={})
        @kexinit ||= P(:byte, KEXINIT,
          :long, rand(0xFFFFFFFF), :long, rand(0xFFFFFFFF), :long, rand(0xFFFFFFFF), :long, rand(0xFFFFFFFF),
          :string, options[:kex] || "diffie-hellman-group-exchange-sha1,diffie-hellman-group1-sha1",
          :string, options[:host_key] || "ssh-rsa,ssh-dss",
          :string, options[:encryption_client] || "aes128-cbc,3des-cbc,blowfish-cbc,cast128-cbc,aes192-cbc,aes256-cbc,rijndael-cbc@lysator.liu.se,idea-cbc",
          :string, options[:encryption_server] || "aes128-cbc,3des-cbc,blowfish-cbc,cast128-cbc,aes192-cbc,aes256-cbc,rijndael-cbc@lysator.liu.se,idea-cbc",
          :string, options[:hmac_client] || "hmac-sha1,hmac-md5,hmac-sha1-96,hmac-md5-96",
          :string, options[:hmac_server] || "hmac-sha1,hmac-md5,hmac-sha1-96,hmac-md5-96",
          :string, options[:compmression_client] || "none,zlib@openssh.com,zlib",
          :string, options[:compmression_server] || "none,zlib@openssh.com,zlib",
          :string, options[:language_client] || "",
          :string, options[:langauge_server] || "",
          :bool, options[:first_kex_follows])
      end

      def assert_kexinit(buffer, options={})
        assert_equal KEXINIT, buffer.type
        assert_equal 16, buffer.read(16).length
        assert_equal options[:kex] || "diffie-hellman-group-exchange-sha1,diffie-hellman-group1-sha1", buffer.read_string
        assert_equal options[:host_key] || "ssh-rsa,ssh-dss", buffer.read_string
        assert_equal options[:encryption_client] || "aes128-cbc,3des-cbc,blowfish-cbc,cast128-cbc,aes192-cbc,aes256-cbc,rijndael-cbc@lysator.liu.se,idea-cbc,none,arcfour128,arcfour256", buffer.read_string
        assert_equal options[:encryption_server] || "aes128-cbc,3des-cbc,blowfish-cbc,cast128-cbc,aes192-cbc,aes256-cbc,rijndael-cbc@lysator.liu.se,idea-cbc,none,arcfour128,arcfour256", buffer.read_string
        assert_equal options[:hmac_client] || "hmac-sha1,hmac-md5,hmac-sha1-96,hmac-md5-96,none", buffer.read_string
        assert_equal options[:hmac_server] || "hmac-sha1,hmac-md5,hmac-sha1-96,hmac-md5-96,none", buffer.read_string
        assert_equal options[:compression_client] || "none,zlib@openssh.com,zlib", buffer.read_string
        assert_equal options[:compression_server] || "none,zlib@openssh.com,zlib", buffer.read_string
        assert_equal options[:language_client] || "", buffer.read_string
        assert_equal options[:language_server] || "", buffer.read_string
        assert_equal options[:first_kex_follows] || false, buffer.read_bool
      end

      def assert_exchange_results
        assert algorithms.initialized?
        assert !algorithms.pending?
        assert !transport.client_options[:compression]
        assert !transport.server_options[:compression]
        assert_equal :client_cipher, transport.client_options[:cipher]
        assert_equal :server_cipher, transport.server_options[:cipher]
        assert_equal :client_hmac, transport.client_options[:hmac]
        assert_equal :server_hmac, transport.server_options[:hmac]
      end

      def algorithms(options={})
        @algorithms ||= Net::SSH::Transport::Algorithms.new(transport, options)
      end

      def transport
        @transport ||= MockTransport.new
      end
  end

end