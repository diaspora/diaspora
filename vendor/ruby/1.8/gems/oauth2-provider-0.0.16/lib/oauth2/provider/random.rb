require 'oauth2/provider'

module OAuth2::Provider::Random
  module Base62
    CHARS = ('0'..'9').to_a + ('a'..'z').to_a + ('A'..'Z').to_a

    # Adapted from http://refactormycode.com/codes/125-base-62-encoding
    def self.encode(i)
      return '0' if i == 0
      s = ''
      while i > 0
        s << CHARS[i.modulo(62)]
        i /= 62
      end
      s.reverse!
      s
    end
  end

  def base62(length = 8)
    number = ActiveSupport::SecureRandom.random_number(62 ** length)
    Base62.encode(number).rjust(length, '0')
  end

  def base36(length = 8)
    ActiveSupport::SecureRandom.random_number(36 ** length).to_s(36).rjust(length, '0')
  end

  module_function :base62, :base36
end