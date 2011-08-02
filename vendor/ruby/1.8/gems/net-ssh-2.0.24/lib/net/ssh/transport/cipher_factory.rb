require 'openssl'
require 'net/ssh/transport/identity_cipher'

module Net; module SSH; module Transport

  # Implements a factory of OpenSSL cipher algorithms.
  class CipherFactory
    # Maps the SSH name of a cipher to it's corresponding OpenSSL name
    SSH_TO_OSSL = {
      "3des-cbc"                    => "des-ede3-cbc",
      "blowfish-cbc"                => "bf-cbc",
      "aes256-cbc"                  => "aes-256-cbc",
      "aes192-cbc"                  => "aes-192-cbc",
      "aes128-cbc"                  => "aes-128-cbc",
      "idea-cbc"                    => "idea-cbc",
      "cast128-cbc"                 => "cast-cbc",
      "rijndael-cbc@lysator.liu.se" => "aes-256-cbc",
      "arcfour128"                  => "rc4",
      "arcfour256"                  => "rc4",
      "arcfour512"                  => "rc4",
      "none"                        => "none"
    }
    
    # Ruby's OpenSSL bindings always return a key length of 16 for RC4 ciphers
    # resulting in the error: OpenSSL::CipherError: key length too short. 
    # The following ciphers will override this key length. 
    KEY_LEN_OVERRIDE = {
      "arcfour256"                  => 32,
      "arcfour512"                  => 64
    }
    
    # Returns true if the underlying OpenSSL library supports the given cipher,
    # and false otherwise.
    def self.supported?(name)
      ossl_name = SSH_TO_OSSL[name] or raise NotImplementedError, "unimplemented cipher `#{name}'"
      return true if ossl_name == "none"
      return OpenSSL::Cipher.ciphers.include?(ossl_name)
    end

    # Retrieves a new instance of the named algorithm. The new instance
    # will be initialized using an iv and key generated from the given
    # iv, key, shared, hash and digester values. Additionally, the
    # cipher will be put into encryption or decryption mode, based on the
    # value of the +encrypt+ parameter.
    def self.get(name, options={})
      ossl_name = SSH_TO_OSSL[name] or raise NotImplementedError, "unimplemented cipher `#{name}'"
      return IdentityCipher if ossl_name == "none"

      cipher = OpenSSL::Cipher::Cipher.new(ossl_name)
      cipher.send(options[:encrypt] ? :encrypt : :decrypt)

      cipher.padding = 0
      cipher.iv      = make_key(cipher.iv_len, options[:iv], options) if ossl_name != "rc4"
      key_len = KEY_LEN_OVERRIDE[name] || cipher.key_len
      cipher.key_len = key_len
      cipher.key     = make_key(key_len, options[:key], options)
      cipher.update(" " * 1536) if ossl_name == "rc4"

      return cipher
    end

    # Returns a two-element array containing the [ key-length,
    # block-size ] for the named cipher algorithm. If the cipher
    # algorithm is unknown, or is "none", 0 is returned for both elements
    # of the tuple.
    def self.get_lengths(name)
      ossl_name = SSH_TO_OSSL[name]
      return [0, 0] if ossl_name.nil? || ossl_name == "none"

      cipher = OpenSSL::Cipher::Cipher.new(ossl_name)
      key_len = KEY_LEN_OVERRIDE[name] || cipher.key_len
      cipher.key_len = key_len
      
      return [key_len, ossl_name=="rc4" ? 8 : cipher.block_size]
    end

    private

      # Generate a key value in accordance with the SSH2 specification.
      def self.make_key(bytes, start, options={})
        k = start[0, bytes]
        
        digester = options[:digester] or raise 'No digester supplied'
        shared   = options[:shared] or raise 'No shared secret supplied'
        hash     = options[:hash] or raise 'No hash supplied'

        while k.length < bytes
          step = digester.digest(shared + hash + k)
          bytes_needed = bytes - k.length
          k << step[0, bytes_needed]
        end

        return k
      end
  end

end; end; end
