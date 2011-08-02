require 'common'
require 'transport/kex/test_diffie_hellman_group1_sha1'
require 'net/ssh/transport/kex/diffie_hellman_group_exchange_sha1'

module Transport; module Kex

  class TestDiffieHellmanGroupExchangeSHA1 < TestDiffieHellmanGroup1SHA1
    KEXDH_GEX_GROUP   = 31
    KEXDH_GEX_INIT    = 32
    KEXDH_GEX_REPLY   = 33
    KEXDH_GEX_REQUEST = 34

    def test_exchange_with_fewer_than_minimum_bits_uses_minimum_bits
      dh_options :need_bytes => 20
      assert_equal 1024, need_bits
      assert_nothing_raised { exchange! }
    end

    def test_exchange_with_fewer_than_maximum_bits_uses_need_bits
      dh_options :need_bytes => 500
      need_bits(4000)
      assert_nothing_raised { exchange! }
    end

    def test_exchange_with_more_than_maximum_bits_uses_maximum_bits
      dh_options :need_bytes => 2000
      need_bits(8192)
      assert_nothing_raised { exchange! }
    end

    def test_that_p_and_g_are_provided_by_the_server
      assert_nothing_raised { exchange! :p => default_p+2, :g => 3 }
      assert_equal default_p+2, dh.dh.p
      assert_equal 3, dh.dh.g
    end

    private

      def need_bits(bits=1024)
        @need_bits ||= bits
      end

      def default_p
        142326151570335518660743995281621698377057354949884468943021767573608899048361360422513557553514790045512299468953431585300812548859419857171094366358158903433167915517332113861059747425408670144201099811846875730766487278261498262568348338476437200556998366087779709990807518291581860338635288400119315130179
      end

      def exchange!(options={})
        connection.expect do |t, buffer|
          assert_equal KEXDH_GEX_REQUEST, buffer.type
          assert_equal 1024, buffer.read_long
          assert_equal need_bits, buffer.read_long
          assert_equal 8192, buffer.read_long
          t.return(KEXDH_GEX_GROUP, :bignum, bn(options[:p] || default_p), :bignum, bn(options[:g] || 2))
          t.expect do |t2, buffer2|
            assert_equal KEXDH_GEX_INIT, buffer2.type
            assert_equal dh.dh.pub_key, buffer2.read_bignum
            t2.return(KEXDH_GEX_REPLY, :string, b(:key, server_key), :bignum, server_dh_pubkey, :string, b(:string, options[:key_type] || "ssh-rsa", :string, signature))
            t2.expect do |t3, buffer3|
              assert_equal NEWKEYS, buffer3.type
              t3.return(NEWKEYS)
            end
          end
        end

        dh.exchange_keys
      end

      def subject
        Net::SSH::Transport::Kex::DiffieHellmanGroupExchangeSHA1
      end

      def session_id
        @session_id ||= begin
          buffer = Net::SSH::Buffer.from(:string, packet_data[:client_version_string],
            :string, packet_data[:server_version_string],
            :string, packet_data[:client_algorithm_packet],
            :string, packet_data[:server_algorithm_packet],
            :string, Net::SSH::Buffer.from(:key, server_key),
            :long,   1024,
            :long,   need_bits, # need bits, figure this part out,
            :long,   8192,
            :bignum, dh.dh.p,
            :bignum, dh.dh.g,
            :bignum, dh.dh.pub_key,
            :bignum, server_dh_pubkey,
            :bignum, shared_secret)
          OpenSSL::Digest::SHA1.digest(buffer.to_s)
        end
      end
  end

end; end