include Java
module BSON
  class BSON_JAVA

    # TODO: Pool or cache instances of RubyBSONEncoder so that
    # we don't create a new one on each call to #serialize.
    def self.serialize(obj, check_keys=false, move_id=false)
      raise InvalidDocument, "BSON_JAVA.serialize takes a Hash" unless obj.is_a?(Hash)
      enc = Java::OrgJbson::RubyBSONEncoder.new(JRuby.runtime)
      ByteBuffer.new(enc.encode(obj))
    end

    def self.deserialize(buf)
      dec = Java::OrgBson::BSONDecoder.new
      callback = Java::OrgJbson::RubyBSONCallback.new(JRuby.runtime)
      dec.decode(buf.to_s.to_java_bytes, callback)
      callback.get
    end

  end
end
