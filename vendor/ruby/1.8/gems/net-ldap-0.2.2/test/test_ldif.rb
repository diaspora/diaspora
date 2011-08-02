# $Id: testldif.rb 61 2006-04-18 20:55:55Z blackhedd $

require 'common'

require 'digest/sha1'
require 'base64'

class TestLdif < Test::Unit::TestCase
  TestLdifFilename = "#{File.dirname(__FILE__)}/testdata.ldif"

  def test_empty_ldif
    ds = Net::LDAP::Dataset.read_ldif(StringIO.new)
    assert_equal(true, ds.empty?)
  end

  def test_ldif_with_comments
    str = ["# Hello from LDIF-land", "# This is an unterminated comment"]
    io = StringIO.new(str[0] + "\r\n" + str[1])
    ds = Net::LDAP::Dataset::read_ldif(io)
    assert_equal(str, ds.comments)
  end

  def test_ldif_with_password
    psw = "goldbricks"
    hashed_psw = "{SHA}" + Base64::encode64(Digest::SHA1.digest(psw)).chomp

    ldif_encoded = Base64::encode64(hashed_psw).chomp
    ds = Net::LDAP::Dataset::read_ldif(StringIO.new("dn: Goldbrick\r\nuserPassword:: #{ldif_encoded}\r\n\r\n"))
    recovered_psw = ds["Goldbrick"][:userpassword].shift
    assert_equal(hashed_psw, recovered_psw)
  end

  def test_ldif_with_continuation_lines
    ds = Net::LDAP::Dataset::read_ldif(StringIO.new("dn: abcdefg\r\n   hijklmn\r\n\r\n"))
    assert_equal(true, ds.has_key?("abcdefg hijklmn"))
  end

  # TODO, INADEQUATE. We need some more tests
  # to verify the content.
  def test_ldif
    File.open(TestLdifFilename, "r") {|f|
      ds = Net::LDAP::Dataset::read_ldif(f)
      assert_equal(13, ds.length)
    }
  end

  # Must test folded lines and base64-encoded lines as well as normal ones.
  def test_to_ldif
    data = File.open(TestLdifFilename, "rb") { |f| f.read }
    io = StringIO.new(data)

    # added .lines to turn to array because 1.9 doesn't have
    # .grep on basic strings
    entries = data.lines.grep(/^dn:\s*/) { $'.chomp }
    dn_entries = entries.dup

    ds = Net::LDAP::Dataset::read_ldif(io) { |type, value|
      case type
      when :dn
        assert_equal(dn_entries.first, value)
        dn_entries.shift
      end
    }
    assert_equal(entries.size, ds.size)
    assert_equal(entries.sort, ds.to_ldif.grep(/^dn:\s*/) { $'.chomp })
  end
end
