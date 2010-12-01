# encoding: ASCII-8BIT
require 'common'

class TestBer < Test::Unit::TestCase

  def test_encode_boolean
    assert_equal( "\x01\x01\x01", true.to_ber ) # should actually be: 01 01 ff
    assert_equal( "\x01\x01\x00", false.to_ber )
  end

  #def test_encode_nil
  # assert_equal( "\x05\x00", nil.to_ber )
  #end

  def test_encode_integer

    # Fixnum
    #
    #assert_equal( "\x02\x02\x96\x46", -27_066.to_ber )
    #assert_equal( "\x02\x02\xFF\x7F", -129.to_ber )
    #assert_equal( "\x02\x01\x80", -128.to_ber )
    #assert_equal( "\x02\x01\xFF", -1.to_ber )

    assert_equal( "\x02\x01\x00", 0.to_ber )
    assert_equal( "\x02\x01\x01", 1.to_ber )
    assert_equal( "\x02\x01\x7F", 127.to_ber )
    assert_equal( "\x02\x01\x80", 128.to_ber )
    assert_equal( "\x02\x01\xFF", 255.to_ber )

    assert_equal( "\x02\x02\x01\x00", 256.to_ber )
    assert_equal( "\x02\x02\xFF\xFF", 65535.to_ber )

    assert_equal( "\x02\x03\x01\x00\x00", 65536.to_ber )
    assert_equal( "\x02\x03\xFF\xFF\xFF", 16_777_215.to_ber )

    assert_equal( "\x02\x04\x01\x00\x00\x00", 0x01000000.to_ber )
    assert_equal( "\x02\x04\x3F\xFF\xFF\xFF", 0x3FFFFFFF.to_ber )

    # Bignum
    #
    assert_equal( "\x02\x04\x4F\xFF\xFF\xFF", 0x4FFFFFFF.to_ber )
    #assert_equal( "\x02\x05\x00\xFF\xFF\xFF\xFF", 0xFFFFFFFF.to_ber )
  end

  # TOD Add some much bigger numbers
  # 5000000000 is a Bignum, which hits different code.
  def test_ber_integers
    assert_equal( "\002\001\005", 5.to_ber )
    assert_equal( "\002\002\001\364", 500.to_ber )
    assert_equal( "\x02\x02\xC3P", 50000.to_ber )
    assert_equal( "\002\005\001*\005\362\000", 5000000000.to_ber )
  end

  def test_ber_bignums
    # Some of these values are Fixnums and some are Bignums. Different BER code.
    100.times do |p|
      n = 2 << p
      assert_equal(n, n.to_ber.read_ber, "2**#{p} could not be read back")
        
      n = 5 * 10**p
      assert_equal(n, n.to_ber.read_ber)
    end
  end

  def test_ber_parsing
    assert_equal( 6, "\002\001\006".read_ber( Net::LDAP::AsnSyntax ))
    assert_equal( "testing", "\004\007testing".read_ber( Net::LDAP::AsnSyntax ))
  end

  def test_ber_parser_on_ldap_bind_request
    s = StringIO.new(
      "0$\002\001\001`\037\002\001\003\004\rAdministrator\200\vad_is_bogus" )

    assert_equal(
      [1, [3, "Administrator", "ad_is_bogus"]],
      s.read_ber( Net::LDAP::AsnSyntax ))
  end
end
