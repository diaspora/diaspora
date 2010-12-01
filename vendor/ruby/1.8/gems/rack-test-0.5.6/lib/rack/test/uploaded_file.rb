require "tempfile"
require "fileutils"

module Rack
  module Test

    # Wraps a Tempfile with a content type. Including one or more UploadedFile's
    # in the params causes Rack::Test to build and issue a multipart request.
    #
    # Example:
    #   post "/photos", "file" => Rack::Test::UploadedFile.new("me.jpg", "image/jpeg")
    class UploadedFile

      # The filename, *not* including the path, of the "uploaded" file
      attr_reader :original_filename

      # The content type of the "uploaded" file
      attr_accessor :content_type

      def initialize(path, content_type = "text/plain", binary = false)
        raise "#{path} file does not exist" unless ::File.exist?(path)

        @content_type = content_type
        @original_filename = ::File.basename(path)

        @tempfile = Tempfile.new(@original_filename)
        @tempfile.set_encoding(Encoding::BINARY) if @tempfile.respond_to?(:set_encoding)
        @tempfile.binmode if binary

        FileUtils.copy_file(path, @tempfile.path)
      end

      def path
        @tempfile.path
      end

      alias_method :local_path, :path

      def method_missing(method_name, *args, &block) #:nodoc:
        @tempfile.__send__(method_name, *args, &block)
      end

    end

  end
end
