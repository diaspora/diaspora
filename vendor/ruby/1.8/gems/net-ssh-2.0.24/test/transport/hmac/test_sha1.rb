require 'common'
require 'net/ssh/transport/hmac/sha1'

module Transport; module HMAC

  class TestSHA1 < Test::Unit::TestCase
    def test_expected_digest_class
      assert_equal OpenSSL::Digest::SHA1, subject.digest_class
      assert_equal OpenSSL::Digest::SHA1, subject.new.digest_class
    end

    def test_expected_key_length
      assert_equal 20, subject.key_length
      assert_equal 20, subject.new.key_length
    end

    def test_expected_mac_length
      assert_equal 20, subject.mac_length
      assert_equal 20, subject.new.mac_length
    end

    def test_expected_digest
      hmac = subject.new("1234567890123456")
      assert_equal "\000\004W\202\204+&\335\311\251P\266\250\214\276\206;\022U\365", hmac.digest("hello world")
    end

    private

      def subject
        Net::SSH::Transport::HMAC::SHA1
      end
  end

end; end