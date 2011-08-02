require 'common'
require 'transport/hmac/test_sha1'
require 'net/ssh/transport/hmac/sha1_96'

module Transport; module HMAC

  class TestSHA1_96 < TestSHA1
    def test_expected_mac_length
      assert_equal 12, subject.mac_length
      assert_equal 12, subject.new.mac_length
    end

    def test_expected_digest
      hmac = subject.new("1234567890123456")
      assert_equal "\000\004W\202\204+&\335\311\251P\266", hmac.digest("hello world")
    end

    private

      def subject
        Net::SSH::Transport::HMAC::SHA1_96
      end
  end

end; end