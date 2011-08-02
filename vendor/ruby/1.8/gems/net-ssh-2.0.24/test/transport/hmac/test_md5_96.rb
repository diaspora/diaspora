require 'common'
require 'transport/hmac/test_md5'
require 'net/ssh/transport/hmac/md5_96'

module Transport; module HMAC

  class TestMD5_96 < TestMD5
    def test_expected_mac_length
      assert_equal 12, subject.mac_length
      assert_equal 12, subject.new.mac_length
    end

    def test_expected_digest
      hmac = subject.new("1234567890123456")
      assert_equal "\275\345\006\307y~Oi\035<.\341", hmac.digest("hello world")
    end

    private

      def subject
        Net::SSH::Transport::HMAC::MD5_96
      end
  end

end; end