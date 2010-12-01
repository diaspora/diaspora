# encoding: UTF-8

# --
# Copyright (C) 2008-2010 10gen Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ++

# A byte buffer.
module BSON
  class ByteBuffer

    attr_reader :order

    def initialize(initial_data="")
      if initial_data.is_a?(String)
        if initial_data.respond_to?(:force_encoding)
          @str = initial_data.force_encoding('binary')
        else
          @str = initial_data
        end
      else
        @str = initial_data.pack('C*')
      end
      @cursor = @str.length
      @order  = :little_endian
      @int_pack_order    = 'V'
      @double_pack_order = 'E'
    end

    if RUBY_VERSION >= '1.9'
      NULL_BYTE       = "\0".force_encoding('binary').freeze
      UTF8_ENCODING   = Encoding.find('utf-8')
      BINARY_ENCODING = Encoding.find('binary')
      
      def self.to_utf8_binary(str)
        str.encode(UTF8_ENCODING).force_encoding(BINARY_ENCODING)
      end
    else
      NULL_BYTE = "\0"
      
      def self.to_utf8_binary(str)
        begin
        str.unpack("U*")
        rescue => ex
          raise InvalidStringEncoding, "String not valid utf-8: #{str.inspect}"
        end
        str
      end
    end

    def self.serialize_cstr(buf, val)
      buf.append!(to_utf8_binary(val.to_s))
      buf.append!(NULL_BYTE)
    end

    # +endianness+ should be :little_endian or :big_endian. Default is :little_endian
    def order=(endianness)
      @order = endianness
      @int_pack_order = endianness == :little_endian ? 'V' : 'N'
      @double_pack_order = endianness == :little_endian ? 'E' : 'G'
    end

    def rewind
      @cursor = 0
    end

    def position
      @cursor
    end

    def position=(val)
      @cursor = val
    end

    def clear
      @str = ""
      @str.force_encoding('binary') if @str.respond_to?(:force_encoding)
      rewind
    end

    def size
      @str.size
    end
    alias_method :length, :size

    # Appends a second ByteBuffer object, +buffer+, to the current buffer.
    def append!(buffer)
      @str << buffer.to_s
      self
    end

    # Prepends a second ByteBuffer object, +buffer+, to the current buffer.
    def prepend!(buffer)
      @str = buffer.to_s + @str
      self
    end

    def put(byte, offset=nil)
      @cursor = offset if offset
      if more?
        @str[@cursor] = chr(byte)
      else
        ensure_length(@cursor)
        @str << chr(byte)
      end
      @cursor += 1
    end
    
    def put_binary(data, offset=nil)
      @cursor = offset if offset
      if defined?(BINARY_ENCODING)
        data = data.dup.force_encoding(BINARY_ENCODING)
      end
      if more?
        @str[@cursor, data.length] = data
      else
        ensure_length(@cursor)
        @str << data
      end
      @cursor += data.length
    end
    
    def put_array(array, offset=nil)
      @cursor = offset if offset
      if more?
        @str[@cursor, array.length] = array.pack("C*")
      else
        ensure_length(@cursor)
        @str << array.pack("C*")
      end
      @cursor += array.length
    end

    def put_int(i, offset=nil)
      @cursor = offset if offset
      if more?
        @str[@cursor, 4] = [i].pack(@int_pack_order)
      else
        ensure_length(@cursor)
        @str << [i].pack(@int_pack_order)
      end
      @cursor += 4
    end

    def put_long(i, offset=nil)
      offset = @cursor unless offset
      if @int_pack_order == 'N'
        put_int(i >> 32, offset)
        put_int(i & 0xffffffff, offset + 4)
      else
        put_int(i & 0xffffffff, offset)
        put_int(i >> 32, offset + 4)
      end
    end

    def put_double(d, offset=nil)
      a = []
      [d].pack(@double_pack_order).each_byte { |b| a << b }
      put_array(a, offset)
    end

    # If +size+ == nil, returns one byte. Else returns array of bytes of length
    # # +size+.
    if "x"[0].is_a?(Integer)
      def get(len=nil)
        one_byte = len.nil?
        len ||= 1
        check_read_length(len)
        start = @cursor
        @cursor += len
        if one_byte
          @str[start]
        else
          @str[start, len].unpack("C*")
        end
      end
    else
      def get(len=nil)
        one_byte = len.nil?
        len ||= 1
        check_read_length(len)
        start = @cursor
        @cursor += len
        if one_byte
          @str[start, 1].ord
        else
          @str[start, len].unpack("C*")
        end
      end
    end

    def get_int
      check_read_length(4)
      vals = @str[@cursor..@cursor+3]
      @cursor += 4
      vals.unpack(@int_pack_order)[0]
    end

    def get_long
      i1 = get_int
      i2 = get_int
      if @int_pack_order == 'N'
        (i1 << 32) + i2
      else
        (i2 << 32) + i1
      end
    end

    def get_double
      check_read_length(8)
      vals = @str[@cursor..@cursor+7]
      @cursor += 8
      vals.unpack(@double_pack_order)[0]
    end

    def more?
      @cursor < @str.size
    end

    def to_a
      @str.unpack("C*")
    end

    def unpack(args)
      to_a
    end

    def to_s
      @str
    end

    def dump
      i = 0
      @str.each_byte do |c, i|
        $stderr.puts "#{'%04d' % i}: #{'%02x' % c} #{'%03o' % c} #{'%s' % c.chr} #{'%3d' % c}"
        i += 1
      end
    end

    private

    def ensure_length(length)
      if @str.size < length
        @str << NULL_BYTE * (length - @str.size)
      end
    end
    
    def chr(byte)
      if byte < 0
        [byte].pack('c')
      else
        byte.chr
      end
    end
    
    def check_read_length(len)
      raise "attempt to read past end of buffer" if @cursor + len > @str.length
    end

  end
end
