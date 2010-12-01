# = digest/hmac.rb
#
# An implementation of HMAC keyed-hashing algorithm
#
# == Overview
#
# This library adds a method named hmac() to Digest classes, which
# creates a Digest class for calculating HMAC digests.
#
# == Examples
#
#   require 'digest/hmac'
#
#   # one-liner example
#   puts Digest::HMAC.hexdigest("data", "hash key", Digest::SHA1)
#
#   # rather longer one
#   hmac = Digest::HMAC.new("foo", Digest::RMD160)
#
#   buf = ""
#   while stream.read(16384, buf)
#     hmac.update(buf)
#   end
#
#   puts hmac.bubblebabble
#
# == License
#
# Copyright (c) 2006 Akinori MUSHA <knu@iDaemons.org>
#
# Documentation by Akinori MUSHA
#
# All rights reserved.  You can redistribute and/or modify it under
# the same terms as Ruby.
#
#   $Id: hmac.rb 14881 2008-01-04 07:26:14Z akr $
#

require 'digest'

unless defined?(Digest::HMAC)
  module Digest
    class HMAC < Digest::Class
      def initialize(key, digester)
        @md = digester.new

        block_len = @md.block_length

        if key.bytesize > block_len
          key = @md.digest(key)
        end

        ipad = Array.new(block_len).fill(0x36)
        opad = Array.new(block_len).fill(0x5c)

        key.bytes.each_with_index { |c, i|
          ipad[i] ^= c
          opad[i] ^= c
        }

        @key = key.freeze
        @ipad = ipad.inject('') { |s, c| s << c.chr }.freeze
        @opad = opad.inject('') { |s, c| s << c.chr }.freeze
        @md.update(@ipad)
      end

      def initialize_copy(other)
        @md = other.instance_eval { @md.clone }
      end

      def update(text)
        @md.update(text)
        self
      end
      alias << update

      def reset
        @md.reset
        @md.update(@ipad)
        self
      end

      def finish
        d = @md.digest!
        @md.update(@opad)
        @md.update(d)
        @md.digest!
      end
      private :finish

      def digest_length
        @md.digest_length
      end

      def block_length
        @md.block_length
      end

      def inspect
        sprintf('#<%s: key=%s, digest=%s>', self.class.name, @key.inspect, @md.inspect.sub(/^\#<(.*)>$/) { $1 });
      end
    end
  end
end
