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

module BSON
  # A BSON seralizer/deserializer in pure Ruby.
  class BSON_RUBY

    MINKEY = -1
    EOO = 0
    NUMBER = 1
    STRING = 2
    OBJECT = 3
    ARRAY = 4
    BINARY = 5
    UNDEFINED = 6
    OID = 7
    BOOLEAN = 8
    DATE = 9
    NULL = 10
    REGEX = 11
    REF = 12
    CODE = 13
    SYMBOL = 14
    CODE_W_SCOPE = 15
    NUMBER_INT = 16
    TIMESTAMP = 17
    NUMBER_LONG = 18
    MAXKEY = 127

    def initialize
      @buf = ByteBuffer.new
      @encoder = BSON_RUBY
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
      buf.put_binary(to_utf8_binary(val.to_s))
      buf.put_binary(NULL_BYTE)
    end

    def self.serialize_key(buf, key)
      raise InvalidDocument, "Key names / regex patterns must not contain the NULL byte" if key.include? "\x00"
      self.serialize_cstr(buf, key)
    end

    def to_a
      @buf.to_a
    end

    def to_s
      @buf.to_s
    end

    # Serializes an object.
    # Implemented to ensure an API compatible with BSON extension.
    def self.serialize(obj, check_keys=false, move_id=false)
      new.serialize(obj, check_keys, move_id)
    end

    def self.deserialize(buf=nil)
      new.deserialize(buf)
    end

    def serialize(obj, check_keys=false, move_id=false)
      raise(InvalidDocument, "BSON.serialize takes a Hash but got a #{obj.class}") unless obj.is_a?(Hash)
      raise "Document is null" unless obj

      @buf.rewind
      # put in a placeholder for the total size
      @buf.put_int(0)

      # Write key/value pairs. Always write _id first if it exists.
      if move_id
        if obj.has_key? '_id'
          serialize_key_value('_id', obj['_id'], false)
        elsif obj.has_key? :_id
          serialize_key_value('_id', obj[:_id], false)
        end
        obj.each {|k, v| serialize_key_value(k, v, check_keys) unless k == '_id' || k == :_id }
      else
        if obj.has_key?('_id') && obj.has_key?(:_id)
          obj['_id'] = obj.delete(:_id)
        end
        obj.each {|k, v| serialize_key_value(k, v, check_keys) }
      end

      serialize_eoo_element(@buf)
      if @buf.size > 4 * 1024 * 1024
        raise InvalidDocument, "Document is too large (#{@buf.size}). BSON documents are limited to 4MB (#{4 * 1024 * 1024})."
      end
      @buf.put_int(@buf.size, 0)
      @buf
    end

    # Returns the array stored in the buffer.
    # Implemented to ensure an API compatible with BSON extension.
    def unpack(arg)
      @buf.to_a
    end

    def serialize_key_value(k, v, check_keys)
      k = k.to_s
      if check_keys
        if k[0] == ?$
          raise InvalidKeyName.new("key #{k} must not start with '$'")
        end
        if k.include? ?.
          raise InvalidKeyName.new("key #{k} must not contain '.'")
        end
      end
      type = bson_type(v)
      case type
      when STRING, SYMBOL
        serialize_string_element(@buf, k, v, type)
      when NUMBER, NUMBER_INT
        serialize_number_element(@buf, k, v, type)
      when OBJECT
        serialize_object_element(@buf, k, v, check_keys)
      when OID
        serialize_oid_element(@buf, k, v)
      when ARRAY
        serialize_array_element(@buf, k, v, check_keys)
      when REGEX
        serialize_regex_element(@buf, k, v)
      when BOOLEAN
        serialize_boolean_element(@buf, k, v)
      when DATE
        serialize_date_element(@buf, k, v)
      when NULL
        serialize_null_element(@buf, k)
      when REF
        serialize_dbref_element(@buf, k, v)
      when BINARY
        serialize_binary_element(@buf, k, v)
      when UNDEFINED
        serialize_null_element(@buf, k)
      when CODE_W_SCOPE
        serialize_code_w_scope(@buf, k, v)
      when MAXKEY
        serialize_max_key_element(@buf, k)
      when MINKEY
        serialize_min_key_element(@buf, k)
      else
        raise "unhandled type #{type}"
      end
    end

    def deserialize(buf=nil)
      # If buf is nil, use @buf, assumed to contain already-serialized BSON.
      # This is only true during testing.
      if buf.is_a? String
        @buf = ByteBuffer.new(buf.unpack("C*")) if buf
      else
        @buf = ByteBuffer.new(buf.to_a) if buf
      end
      @buf.rewind
      @buf.get_int                # eat message size
      doc = BSON::OrderedHash.new
      while @buf.more?
        type = @buf.get
        case type
        when STRING, CODE
          key = deserialize_cstr(@buf)
          doc[key] = deserialize_string_data(@buf)
        when SYMBOL
          key = deserialize_cstr(@buf)
          doc[key] = deserialize_string_data(@buf).intern
        when NUMBER
          key = deserialize_cstr(@buf)
          doc[key] = deserialize_number_data(@buf)
        when NUMBER_INT
          key = deserialize_cstr(@buf)
          doc[key] = deserialize_number_int_data(@buf)
        when NUMBER_LONG
          key = deserialize_cstr(@buf)
          doc[key] = deserialize_number_long_data(@buf)
        when OID
          key = deserialize_cstr(@buf)
          doc[key] = deserialize_oid_data(@buf)
        when ARRAY
          key = deserialize_cstr(@buf)
          doc[key] = deserialize_array_data(@buf)
        when REGEX
          key = deserialize_cstr(@buf)
          doc[key] = deserialize_regex_data(@buf)
        when OBJECT
          key = deserialize_cstr(@buf)
          doc[key] = deserialize_object_data(@buf)
        when BOOLEAN
          key = deserialize_cstr(@buf)
          doc[key] = deserialize_boolean_data(@buf)
        when DATE
          key = deserialize_cstr(@buf)
          doc[key] = deserialize_date_data(@buf)
        when NULL
          key = deserialize_cstr(@buf)
          doc[key] = nil
        when UNDEFINED
          key = deserialize_cstr(@buf)
          doc[key] = nil
        when REF
          key = deserialize_cstr(@buf)
          doc[key] = deserialize_dbref_data(@buf)
        when BINARY
          key = deserialize_cstr(@buf)
          doc[key] = deserialize_binary_data(@buf)
        when CODE_W_SCOPE
          key = deserialize_cstr(@buf)
          doc[key] = deserialize_code_w_scope_data(@buf)
        when TIMESTAMP
          key = deserialize_cstr(@buf)
          doc[key] = [deserialize_number_int_data(@buf),
          deserialize_number_int_data(@buf)]
        when MAXKEY
          key = deserialize_cstr(@buf)
          doc[key] = MaxKey.new
        when MINKEY, 255 # This is currently easier than unpack the type byte as an unsigned char.
          key = deserialize_cstr(@buf)
          doc[key] = MinKey.new
        when EOO
          break
        else
          raise "Unknown type #{type}, key = #{key}"
        end
      end
      @buf.rewind
      doc
    end

    # For debugging.
    def hex_dump
      str = ''
      @buf.to_a.each_with_index { |b,i|
        if (i % 8) == 0
          str << "\n" if i > 0
          str << '%4d:  ' % i
        else
          str << ' '
        end
        str << '%02X' % b
      }
      str
    end

    def deserialize_date_data(buf)
      unsigned = buf.get_long()
      milliseconds = unsigned >= 2 ** 64 / 2 ? unsigned - 2**64 : unsigned
      Time.at(milliseconds.to_f / 1000.0).utc # at() takes fractional seconds
    end

    def deserialize_boolean_data(buf)
      buf.get == 1
    end

    def deserialize_number_data(buf)
      buf.get_double
    end

    def deserialize_number_int_data(buf)
      unsigned = buf.get_int
      unsigned >= 2**32 / 2 ? unsigned - 2**32 : unsigned
    end

    def deserialize_number_long_data(buf)
      unsigned = buf.get_long
      unsigned >= 2 ** 64 / 2 ? unsigned - 2**64 : unsigned
    end

    def deserialize_object_data(buf)
      size = buf.get_int
      buf.position -= 4
      object = @encoder.new().deserialize(buf.get(size))
      if object.has_key? "$ref"
        DBRef.new(object["$ref"], object["$id"])
      else
        object
      end
    end

    def deserialize_array_data(buf)
      h = deserialize_object_data(buf)
      a = []
      h.each { |k, v| a[k.to_i] = v }
      a
    end

    def deserialize_regex_data(buf)
      str = deserialize_cstr(buf)
      options_str = deserialize_cstr(buf)
      options = 0
      options |= Regexp::IGNORECASE if options_str.include?('i')
      options |= Regexp::MULTILINE if options_str.include?('m')
      options |= Regexp::EXTENDED if options_str.include?('x')
      Regexp.new(str, options)
    end

    def encoded_str(str)
      if RUBY_VERSION >= '1.9'
        str.force_encoding("utf-8")
        if Encoding.default_internal
          str.encode!(Encoding.default_internal)
        end
      end
      str
    end

    def deserialize_string_data(buf)
      len = buf.get_int
      bytes = buf.get(len)
      str = bytes[0..-2]
      if str.respond_to? "pack"
        str = str.pack("C*")
      end
      encoded_str(str)
    end

    def deserialize_code_w_scope_data(buf)
      buf.get_int
      len = buf.get_int
      code = buf.get(len)[0..-2]
      if code.respond_to? "pack"
        code = code.pack("C*")
      end

      scope_size = buf.get_int
      buf.position -= 4
      scope = @encoder.new().deserialize(buf.get(scope_size))

      Code.new(encoded_str(code), scope)
    end

    def deserialize_oid_data(buf)
      ObjectId.new(buf.get(12))
    end

    def deserialize_dbref_data(buf)
      ns = deserialize_string_data(buf)
      oid = deserialize_oid_data(buf)
      DBRef.new(ns, oid)
    end

    def deserialize_binary_data(buf)
      len = buf.get_int
      type = buf.get
      len = buf.get_int if type == Binary::SUBTYPE_BYTES
      Binary.new(buf.get(len), type)
    end

    def serialize_eoo_element(buf)
      buf.put(EOO)
    end

    def serialize_null_element(buf, key)
      buf.put(NULL)
      self.class.serialize_key(buf, key)
    end

    def serialize_dbref_element(buf, key, val)
      oh = BSON::OrderedHash.new
      oh['$ref'] = val.namespace
      oh['$id'] = val.object_id
      serialize_object_element(buf, key, oh, false)
    end

    def serialize_binary_element(buf, key, val)
      buf.put(BINARY)
      self.class.serialize_key(buf, key)

      bytes = val.to_a
      num_bytes = bytes.length
      subtype = val.respond_to?(:subtype) ? val.subtype : Binary::SUBTYPE_BYTES
      if subtype == Binary::SUBTYPE_BYTES
        buf.put_int(num_bytes + 4)
        buf.put(subtype)
        buf.put_int(num_bytes)
        buf.put_array(bytes)
      else
        buf.put_int(num_bytes)
        buf.put(subtype)
        buf.put_array(bytes)
      end
    end

    def serialize_boolean_element(buf, key, val)
      buf.put(BOOLEAN)
      self.class.serialize_key(buf, key)
      buf.put(val ? 1 : 0)
    end

    def serialize_date_element(buf, key, val)
      buf.put(DATE)
      self.class.serialize_key(buf, key)
      millisecs = (val.to_f * 1000).to_i
      buf.put_long(millisecs)
    end

    def serialize_number_element(buf, key, val, type)
      if type == NUMBER
        buf.put(type)
        self.class.serialize_key(buf, key)
        buf.put_double(val)
      else
        if val > 2**64 / 2 - 1 or val < -2**64 / 2
          raise RangeError.new("MongoDB can only handle 8-byte ints")
        end
        if val > 2**32 / 2 - 1 or val < -2**32 / 2
          buf.put(NUMBER_LONG)
          self.class.serialize_key(buf, key)
          buf.put_long(val)
        else
          buf.put(type)
          self.class.serialize_key(buf, key)
          buf.put_int(val)
        end
      end
    end

    def serialize_object_element(buf, key, val, check_keys, opcode=OBJECT)
      buf.put(opcode)
      self.class.serialize_key(buf, key)
      buf.put_array(@encoder.new.serialize(val, check_keys).to_a)
    end

    def serialize_array_element(buf, key, val, check_keys)
      # Turn array into hash with integer indices as keys
      h = BSON::OrderedHash.new
      i = 0
      val.each { |v| h[i] = v; i += 1 }
      serialize_object_element(buf, key, h, check_keys, ARRAY)
    end

    def serialize_regex_element(buf, key, val)
      buf.put(REGEX)
      self.class.serialize_key(buf, key)

      str = val.source
      # We use serialize_key here since regex patterns aren't prefixed with
      # length (can't contain the NULL byte).
      self.class.serialize_key(buf, str)

      options = val.options
      options_str = ''
      options_str << 'i' if ((options & Regexp::IGNORECASE) != 0)
      options_str << 'm' if ((options & Regexp::MULTILINE) != 0)
      options_str << 'x' if ((options & Regexp::EXTENDED) != 0)
      options_str << val.extra_options_str if val.respond_to?(:extra_options_str)
      # Must store option chars in alphabetical order
      self.class.serialize_cstr(buf, options_str.split(//).sort.uniq.join)
    end

    def serialize_max_key_element(buf, key)
      buf.put(MAXKEY)
      self.class.serialize_key(buf, key)
    end

    def serialize_min_key_element(buf, key)
      buf.put(MINKEY)
      self.class.serialize_key(buf, key)
    end

    def serialize_oid_element(buf, key, val)
      buf.put(OID)
      self.class.serialize_key(buf, key)

      buf.put_array(val.to_a)
    end

    def serialize_string_element(buf, key, val, type)
      buf.put(type)
      self.class.serialize_key(buf, key)

      # Make a hole for the length
      len_pos = buf.position
      buf.put_int(0)

      # Save the string
      start_pos = buf.position
      self.class.serialize_cstr(buf, val)
      end_pos = buf.position

      # Put the string size in front
      buf.put_int(end_pos - start_pos, len_pos)

      # Go back to where we were
      buf.position = end_pos
    end

    def serialize_code_w_scope(buf, key, val)
      buf.put(CODE_W_SCOPE)
      self.class.serialize_key(buf, key)

      # Make a hole for the length
      len_pos = buf.position
      buf.put_int(0)

      buf.put_int(val.code.length + 1)
      self.class.serialize_cstr(buf, val.code)
      buf.put_array(@encoder.new.serialize(val.scope).to_a)

      end_pos = buf.position
      buf.put_int(end_pos - len_pos, len_pos)
      buf.position = end_pos
    end

    def deserialize_cstr(buf)
      chars = ""
      while true
        b = buf.get
        break if b == 0
        chars << b.chr
      end
      encoded_str(chars)
    end

    def bson_type(o)
      case o
      when nil
        NULL
      when Integer
        NUMBER_INT
      when Float
        NUMBER
      when ByteBuffer
        BINARY
      when Code
        CODE_W_SCOPE
      when String
        STRING
      when Array
        ARRAY
      when Regexp
        REGEX
      when ObjectId
        OID
      when DBRef
        REF
      when true, false
        BOOLEAN
      when Time
        DATE
      when Hash
        OBJECT
      when Symbol
        SYMBOL
      when MaxKey
        MAXKEY
      when MinKey
        MINKEY
      when Numeric
        raise InvalidDocument, "Cannot serialize the Numeric type #{o.class} as BSON; only Fixum, Bignum, and Float are supported."
      when Date, DateTime
        raise InvalidDocument, "#{o.class} is not currently supported; " +
        "use a UTC Time instance instead."
      else
        if defined?(ActiveSupport::TimeWithZone) && o.is_a?(ActiveSupport::TimeWithZone)
          raise InvalidDocument, "ActiveSupport::TimeWithZone is not currently supported; " +
          "use a UTC Time instance instead."
        else
          raise InvalidDocument, "Cannot serialize #{o.class} as a BSON type; it either isn't supported or won't translate to BSON."
        end
      end
    end

  end
end
