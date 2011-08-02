module Parts
  module Part #:nodoc:
    def self.new(boundary, name, value)
      if value.respond_to? :content_type
        FilePart.new(boundary, name, value)
      else
        ParamPart.new(boundary, name, value)
      end
    end

    def length
      @part.length
    end

    def to_io
      @io
    end
  end

  class ParamPart
    include Part
    def initialize(boundary, name, value)
      @part = build_part(boundary, name, value)
      @io = StringIO.new(@part)
    end

    def build_part(boundary, name, value)
      part = ''
      part << "--#{boundary}\r\n"
      part << "Content-Disposition: form-data; name=\"#{name.to_s}\"\r\n"
      part << "\r\n"
      part << "#{value}\r\n"
    end
  end

  # Represents a part to be filled from file IO.
  class FilePart
    include Part
    attr_reader :length
    def initialize(boundary, name, io)
      file_length = io.respond_to?(:length) ?  io.length : File.size(io.local_path)
      @head = build_head(boundary, name, io.original_filename, io.content_type, file_length,
                         io.respond_to?(:opts) ? io.opts : {})
      @foot = "\r\n"
      @length = @head.length + file_length + @foot.length
      @io = CompositeReadIO.new(StringIO.new(@head), io, StringIO.new(@foot))
    end

    def build_head(boundary, name, filename, type, content_len, opts = {})
      trans_encoding = opts["Content-Transfer-Encoding"] || "binary"
      content_disposition = opts["Content-Disposition"] || "form-data"

      part = ''
      part << "--#{boundary}\r\n"
      part << "Content-Disposition: #{content_disposition}; name=\"#{name.to_s}\"; filename=\"#{filename}\"\r\n"
      part << "Content-Length: #{content_len}\r\n"
      if content_id = opts["Content-ID"]
        part << "Content-ID: #{content_id}\r\n"
      end
      part << "Content-Type: #{type}\r\n"
      part << "Content-Transfer-Encoding: #{trans_encoding}\r\n"
      part << "\r\n"
    end
  end

  # Represents the epilogue or closing boundary.
  class EpiloguePart
    include Part
    def initialize(boundary)
      @part = "--#{boundary}--\r\n\r\n"
      @io = StringIO.new(@part)
    end
  end
end
