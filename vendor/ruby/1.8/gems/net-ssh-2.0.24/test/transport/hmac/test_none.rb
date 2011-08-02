require 'common'
require 'net/ssh/transport/hmac/none'

module Transport; module HMAC

  class TestNone < Test::Unit::TestCase
    def test_expected_digest_class
      assert_equal nil, subject.digest_class
      assert_equal nil, subject.new.digest_class
    end

    def test_expected_key_length
      assert_equal 0, subject.key_length
      assert_equal 0, subject.new.key_length
    end

    def test_expected_mac_length
      assert_equal 0, subject.mac_length
      assert_equal 0, subject.new.mac_length
    end

    def test_expected_digest
      hmac = subject.new("1234567890123456")
      assert_equal "", hmac.digest("hello world")
    end

    private

      def subject
        Net::SSH::Transport::HMAC::None
      end
  end

end; end