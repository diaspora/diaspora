require 'common'
require 'net/ssh/transport/hmac'

module Transport

  class TestHMAC < Test::Unit::TestCase
    Net::SSH::Transport::HMAC::MAP.each do |name, value|
      method = name.tr("-", "_")
      define_method("test_get_with_#{method}_returns_new_hmac_instance") do
        key = "abcdefghijklmnopqrstuvwxyz"[0,Net::SSH::Transport::HMAC::MAP[name].key_length]
        hmac = Net::SSH::Transport::HMAC.get(name, key)
        assert_instance_of Net::SSH::Transport::HMAC::MAP[name], hmac
        assert_equal key, hmac.key
      end

      define_method("test_key_length_with_#{method}_returns_correct_key_length") do
        assert_equal Net::SSH::Transport::HMAC::MAP[name].key_length, Net::SSH::Transport::HMAC.key_length(name)
      end
    end

    def test_get_with_unrecognized_hmac_raises_argument_error
      assert_raises(ArgumentError) do
        Net::SSH::Transport::HMAC.get("bogus")
      end
    end

    def test_key_length_with_unrecognized_hmac_raises_argument_error
      assert_raises(ArgumentError) do
        Net::SSH::Transport::HMAC.get("bogus")
      end
    end
  end

end