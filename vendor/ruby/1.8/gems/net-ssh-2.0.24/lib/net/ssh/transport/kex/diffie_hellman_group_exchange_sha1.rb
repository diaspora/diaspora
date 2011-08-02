require 'net/ssh/errors'
require 'net/ssh/transport/constants'
require 'net/ssh/transport/kex/diffie_hellman_group1_sha1'

module Net::SSH::Transport::Kex

  # A key-exchange service implementing the
  # "diffie-hellman-group-exchange-sha1" key-exchange algorithm.
  class DiffieHellmanGroupExchangeSHA1 < DiffieHellmanGroup1SHA1
    MINIMUM_BITS      = 1024
    MAXIMUM_BITS      = 8192

    KEXDH_GEX_GROUP   = 31
    KEXDH_GEX_INIT    = 32
    KEXDH_GEX_REPLY   = 33
    KEXDH_GEX_REQUEST = 34

    private

      # Compute the number of bits needed for the given number of bytes.
      def compute_need_bits
        need_bits = data[:need_bytes] * 8
        if need_bits < MINIMUM_BITS
          need_bits = MINIMUM_BITS
        elsif need_bits > MAXIMUM_BITS
          need_bits = MAXIMUM_BITS
        end

        data[:need_bits ] = need_bits
        data[:need_bytes] = need_bits / 8
      end

      # Returns the DH key parameters for the given session.
      def get_parameters
        compute_need_bits

        # request the DH key parameters for the given number of bits.
        buffer = Net::SSH::Buffer.from(:byte, KEXDH_GEX_REQUEST, :long, MINIMUM_BITS,
          :long, data[:need_bits], :long, MAXIMUM_BITS)
        connection.send_message(buffer)

        buffer = connection.next_message
        unless buffer.type == KEXDH_GEX_GROUP
          raise Net::SSH::Exception, "expected KEXDH_GEX_GROUP, got #{buffer.type}"
        end

        p = buffer.read_bignum
        g = buffer.read_bignum

        [p, g]
      end

      # Returns the INIT/REPLY constants used by this algorithm.
      def get_message_types
        [KEXDH_GEX_INIT, KEXDH_GEX_REPLY]
      end

      # Build the signature buffer to use when verifying a signature from
      # the server.
      def build_signature_buffer(result)
        response = Net::SSH::Buffer.new
        response.write_string data[:client_version_string],
                              data[:server_version_string],
                              data[:client_algorithm_packet],
                              data[:server_algorithm_packet],
                              result[:key_blob]
        response.write_long MINIMUM_BITS,
                            data[:need_bits],
                            MAXIMUM_BITS
        response.write_bignum dh.p, dh.g, dh.pub_key,
                              result[:server_dh_pubkey],
                              result[:shared_secret]
        response
      end
  end

end