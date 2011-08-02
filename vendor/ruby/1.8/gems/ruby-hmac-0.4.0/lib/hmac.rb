# Copyright (C) 2001  Daiki Ueno <ueno@unixuser.org>
# This library is distributed under the terms of the Ruby license.

# This module provides common interface to HMAC engines.
# HMAC standard is documented in RFC 2104:
#
#   H. Krawczyk et al., "HMAC: Keyed-Hashing for Message Authentication",
#   RFC 2104, February 1997
#
# These APIs are inspired by JCE 1.2's javax.crypto.Mac interface.
#
#   <URL:http://java.sun.com/security/JCE1.2/spec/apidoc/javax/crypto/Mac.html>
#
# Source repository is at
#
#   http://github.com/topfunky/ruby-hmac/tree/master

module HMAC

  VERSION = '0.4.0'

  class Base
    def initialize(algorithm, block_size, output_length, key)
      @algorithm = algorithm
      @block_size = block_size
      @output_length = output_length
      @initialized = false
      @key_xor_ipad = ''
      @key_xor_opad = ''
      set_key(key) unless key.nil?
    end

    private
    def check_status
      unless @initialized
        raise RuntimeError,
        "The underlying hash algorithm has not yet been initialized."
      end
    end

    public
    def set_key(key)
      # If key is longer than the block size, apply hash function
      # to key and use the result as a real key.
      key = @algorithm.digest(key) if key.size > @block_size
      akey = key.unpack("C*")
      key_xor_ipad = ("\x36" * @block_size).unpack("C*")
      key_xor_opad = ("\x5C" * @block_size).unpack("C*")
      for i in 0 .. akey.size - 1
        key_xor_ipad[i] ^= akey[i]
        key_xor_opad[i] ^= akey[i]
      end
      @key_xor_ipad = key_xor_ipad.pack("C*")
      @key_xor_opad = key_xor_opad.pack("C*")
      @md = @algorithm.new
      @initialized = true
    end

    def reset_key
      @key_xor_ipad.gsub!(/./, '?')
      @key_xor_opad.gsub!(/./, '?')
      @key_xor_ipad[0..-1] = ''
      @key_xor_opad[0..-1] = ''
      @initialized = false
    end

    def update(text)
      check_status
      # perform inner H
      md = @algorithm.new
      md.update(@key_xor_ipad)
      md.update(text)
      str = md.digest
      # perform outer H
      md = @algorithm.new
      md.update(@key_xor_opad)
      md.update(str)
      @md = md
    end
    alias << update

    def digest
      check_status
      @md.digest
    end

    def hexdigest
      check_status
      @md.hexdigest
    end
    alias to_s hexdigest

    # These two class methods below are safer than using above
    # instance methods combinatorially because an instance will have
    # held a key even if it's no longer in use.
    def Base.digest(key, text)
      hmac = self.new(key)
      begin
        hmac.update(text)
        hmac.digest
      ensure
        hmac.reset_key
      end
    end

    def Base.hexdigest(key, text)
      hmac = self.new(key)
      begin
        hmac.update(text)
        hmac.hexdigest
      ensure
        hmac.reset_key
      end
    end

    private_class_method :new, :digest, :hexdigest
  end
end
