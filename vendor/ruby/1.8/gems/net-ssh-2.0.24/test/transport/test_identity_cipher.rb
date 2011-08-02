require 'common'
require 'net/ssh/transport/identity_cipher'

module Transport

  class TestIdentityCipher < Test::Unit::TestCase

    def test_block_size_should_be_8
      assert_equal 8, cipher.block_size
    end

    def test_encrypt_should_return_self
      assert_equal cipher, cipher.encrypt
    end

    def test_decrypt_should_return_self
      assert_equal cipher, cipher.decrypt
    end

    def test_update_should_return_argument
      assert_equal "hello, world", cipher.update("hello, world")
    end

    def test_final_should_return_empty_string
      assert_equal "", cipher.final
    end

    def test_name_should_be_identity
      assert_equal "identity", cipher.name
    end

    private

      def cipher
        Net::SSH::Transport::IdentityCipher
      end

  end

end
