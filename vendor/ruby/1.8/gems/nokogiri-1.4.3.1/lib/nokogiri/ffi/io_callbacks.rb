# :stopdoc:
module Nokogiri
  module IoCallbacks

    class << self

      def plain_old_reader(io)
        lambda do |ctx, buffer, len|
          string = io.read(len)
          return 0 if string.nil?
          buffer.put_bytes(0, string, 0, string.length)
          string.length
        end
      end

      if defined?(FFI::IO.native_read)
        def ffi_io_native_reader(io)
          if io.is_a?(StringIO)
            plain_old_reader(io)
          else
            lambda do |ctx, buffer, len|
              rcode = FFI::IO.native_read(io, buffer, len)
              (rcode < 0) ? 0 : rcode
            end
          end
        end
        alias :reader :ffi_io_native_reader
      else
        alias :reader :plain_old_reader
      end

      def writer(io)
        lambda do |context, buffer, len|
          io.write buffer
          len
        end
      end
    end

  end
end
# :startdoc:
