require File.expand_path('../../../oauth_case', __FILE__)

# See http://oauth.net/core/1.0/#encoding_parameters
#
# 5.1.  Parameter Encoding
#
# All parameter names and values are escaped using the [RFC3986] percent-encoding (%xx) mechanism.
# Characters not in the unreserved character set ([RFC3986] section 2.3) MUST be encoded. Characters
# in the unreserved character set MUST NOT be encoded. Hexadecimal characters in encodings MUST be
# upper case. Text names and values MUST be encoded as UTF-8 octets before percent-encoding them per [RFC3629].
#
#   unreserved = ALPHA, DIGIT, '-', '.', '_', '~'
#

class ParameterEncodingTest < OAuthCase
  def test_encodings_alpha_num
    assert_encoding 'abcABC123', 'abcABC123'
  end

  def test_encodings_non_escaped
    assert_encoding '-._~', '-._~'
  end

  def test_encodings_percent
    assert_encoding '%25', '%'
  end

  def test_encodings_plus
    assert_encoding '%2B', '+'
  end

  def test_encodings_space
    assert_encoding '%20', ' '
  end

  def test_encodings_query_param_symbols
    assert_encoding '%26%3D%2A', '&=*'
  end

  def test_encodings_unicode_lf
    assert_encoding '%0A', unicode_to_utf8('U+000A')
  end

  def test_encodings_unicode_space
    assert_encoding '%20', unicode_to_utf8('U+0020')
  end

  def test_encodings_unicode_007f
    assert_encoding '%7F', unicode_to_utf8('U+007F')
  end

  def test_encodings_unicode_0080
    assert_encoding '%C2%80', unicode_to_utf8('U+0080')
  end

  def test_encoding_unicode_2708
    assert_encoding '%E2%9C%88', unicode_to_utf8('U+2708')
  end

  def test_encodings_unicode_3001
    assert_encoding '%E3%80%81', unicode_to_utf8('U+3001')
  end

protected

  def unicode_to_utf8(unicode)
    return unicode if unicode =~ /\A[[:space:]]*\z/m

    str = ''

    unicode.scan(/(U\+(?:[[:digit:][:xdigit:]]{4,5}|10[[:digit:][:xdigit:]]{4})|.)/mu) do
      c = $1
      if c =~ /^U\+/
        str << [c[2..-1].hex].pack('U*')
      else
        str << c
      end
    end

    str
  end

  def assert_encoding(expected, given, message = nil)
    assert_equal expected, OAuth::Helper.escape(given), message
  end
end
