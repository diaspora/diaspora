require 'time'
require 'rack/utils'
require 'rack/mime'

module HostMeta

  #
  # Serve just a 'host-meta' request from a static file.
  #
  class File
    attr_accessor :root
    attr_accessor :path

    alias :to_path :path

    def initialize(root)
      @root = root
    end

    def call(env)
      dup._call(env)
    end

    F = ::File

    def _call(env)
      @path_info = Rack::Utils.unescape(env["PATH_INFO"])
      @path = F.join(@root, @path_info)

      available = begin
        @path_info == "/host-meta" && F.file?(@path) && F.readable?(@path)
      rescue SystemCallError
        false
      end

      if available
        serving(env)
      else
        fail(404, "File not found: #{@path_info}")
      end
    end

    def serving(env)
      # NOTE:
      #   We check via File::size? whether this file provides size info
      #   via stat (e.g. /proc files often don't), otherwise we have to
      #   figure it out by reading the whole file into memory.
      @size = F.size?(@path) || Rack::Utils.bytesize(F.read(@path))
      response = [
        200,
        {
          "Last-Modified"  => F.mtime(@path).httpdate,
          "Content-Type"   => 'application/xml+xrd; charset=utf-8'
        },
        self
      ]
      response[1]["Content-Length"] = @size.to_s
      response
    end

    def each
      F.open(@path) do |file|
        yield file.read( @size)
      end
    end

    private

    def fail(status, body)
      body += "\n"
      [
        status,
        {
          "Content-Type" => "text/plain",
          "Content-Length" => body.size.to_s,
          "X-Cascade" => "pass"
        },
        [body]
      ]
    end

  end
end
