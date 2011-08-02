#!/usr/bin/env ruby

$: << File.dirname(__FILE__) + "/../lib"
require "hmac-md5"
require "hmac-sha1"
begin
  require "minitest/unit"
rescue LoadError
  require "rubygems"
  require "minitest/unit"
end

MiniTest::Unit.autorun

class TestHmac < MiniTest::Unit::TestCase

  def test_s_digest
    key = "\x0b" * 16
    text = "Hi There"

    hmac = HMAC::MD5.new(key)
    hmac.update(text)

    assert_equal(hmac.digest, HMAC::MD5.digest(key, text))
  end

  def test_s_hexdigest
    key = "\x0b" * 16
    text = "Hi There"

    hmac = HMAC::MD5.new(key)
    hmac.update(text)

    assert_equal(hmac.hexdigest, HMAC::MD5.hexdigest(key, text))
  end

  def test_hmac_md5_1
    assert_equal(HMAC::MD5.hexdigest("\x0b" * 16, "Hi There"),
                 "9294727a3638bb1c13f48ef8158bfc9d")
  end

  def test_hmac_md5_2
    assert_equal(HMAC::MD5.hexdigest("Jefe", "what do ya want for nothing?"),
                 "750c783e6ab0b503eaa86e310a5db738")
  end

  def test_hmac_md5_3
    assert_equal(HMAC::MD5.hexdigest("\xaa" * 16, "\xdd" * 50),
                 "56be34521d144c88dbb8c733f0e8b3f6")
  end

  def test_hmac_md5_4
    assert_equal(HMAC::MD5.hexdigest(["0102030405060708090a0b0c0d0e0f10111213141516171819"].pack("H*"), "\xcd" * 50),
                 "697eaf0aca3a3aea3a75164746ffaa79")
  end

  def test_hmac_md5_5
    assert_equal(HMAC::MD5.hexdigest("\x0c" * 16, "Test With Truncation"),
                 "56461ef2342edc00f9bab995690efd4c")
  end

  #  def test_hmac_md5_6
  #    assert_equal(HMAC::MD5.hexdigest("\x0c" * 16, "Test With Truncation"),
  #      "56461ef2342edc00f9bab995")
  #  end

  def test_hmac_md5_7
    assert_equal(HMAC::MD5.hexdigest("\xaa" * 80, "Test Using Larger Than Block-Size Key - Hash Key First"),
                 "6b1ab7fe4bd7bf8f0b62e6ce61b9d0cd")
  end

  def test_hmac_md5_8
    assert_equal(HMAC::MD5.hexdigest("\xaa" * 80, "Test Using Larger Than Block-Size Key and Larger Than One Block-Size Data"),
                 "6f630fad67cda0ee1fb1f562db3aa53e")
  end

  def test_reset_key
    hmac = HMAC::MD5.new("key")
    hmac.reset_key
    assert_raises(RuntimeError) { hmac.update("foo") }
  end

  def test_set_key
    hmac = HMAC::MD5.new
    assert_raises(RuntimeError) { hmac.update("foo") }
    hmac.reset_key
    assert_raises(RuntimeError) { hmac.update("foo") }
  end
end
