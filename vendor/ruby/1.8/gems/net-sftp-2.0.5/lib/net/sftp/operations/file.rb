require 'net/ssh/loggable'
require 'net/sftp/operations/file'

module Net; module SFTP; module Operations

  # A wrapper around an SFTP file handle, that exposes an IO-like interface
  # for interacting with the remote file. All operations are synchronous
  # (blocking), making this a very convenient way to deal with remote files.
  #
  # A wrapper is usually created via the Net::SFTP::Session#file factory:
  #
  #   file = sftp.file.open("/path/to/remote")
  #   puts file.gets
  #   file.close
  class File
    # A reference to the Net::SFTP::Session instance that drives this wrapper
    attr_reader :sftp

    # The SFTP file handle object that this object wraps
    attr_reader :handle

    # The current position within the remote file
    attr_reader :pos

    # Creates a new wrapper that encapsulates the given +handle+ (such as
    # would be returned by Net::SFTP::Session#open!). The +sftp+ parameter
    # must be the same Net::SFTP::Session instance that opened the file.
    def initialize(sftp, handle)
      @sftp     = sftp
      @handle   = handle
      @pos      = 0
      @real_pos = 0
      @real_eof = false
      @buffer   = ""
    end

    # Repositions the file pointer to the given offset (relative to the
    # start of the file). This will also reset the EOF flag.
    def pos=(offset)
      @real_pos = @pos = offset
      @buffer = ""
      @real_eof = false
    end

    # Closes the underlying file and sets the handle to +nil+. Subsequent
    # operations on this object will fail.
    def close
      sftp.close!(handle)
      @handle = nil
    end

    # Returns true if the end of the file has been encountered by a previous
    # read. Setting the current file position via #pos= will reset this
    # flag (useful if the file's contents have changed since the EOF was
    # encountered).
    def eof?
      @real_eof && @buffer.empty?
    end

    # Reads up to +n+ bytes of data from the stream. Fewer bytes will be
    # returned if EOF is encountered before the requested number of bytes
    # could be read. Without an argument (or with a nil argument) all data
    # to the end of the file will be read and returned.
    #
    # This will advance the file pointer (#pos).
    def read(n=nil)
      loop do
        break if n && @buffer.length >= n
        break unless fill
      end

      if n
        result, @buffer = @buffer[0,n], (@buffer[n..-1] || "")
      else
        result, @buffer = @buffer, ""
      end

      @pos += result.length
      return result
    end

    # Reads up to the next instance of +sep_string+ in the stream, and
    # returns the bytes read (including +sep_string+). If +sep_string+ is
    # omitted, it defaults to +$/+. If EOF is encountered before any data
    # could be read, #gets will return +nil+.
    def gets(sep_string=$/)
      delim = if sep_string.length == 0
        "#{$/}#{$/}"
      else
        sep_string
      end

      loop do
        at = @buffer.index(delim)
        if at
          offset = at + delim.length
          @pos += offset
          line, @buffer = @buffer[0,offset], @buffer[offset..-1]
          return line
        elsif !fill
          return nil if @buffer.empty?
          @pos += @buffer.length
          line, @buffer = @buffer, ""
          return line
        end
      end
    end

    # Same as #gets, but raises EOFError if EOF is encountered before any
    # data could be read.
    def readline(sep_string=$/)
      line = gets(sep_string)
      raise EOFError if line.nil?
      return line
    end

    # Writes the given data to the stream, incrementing the file position and
    # returning the number of bytes written.
    def write(data)
      data = data.to_s
      sftp.write!(handle, @real_pos, data)
      @real_pos += data.length
      @pos = @real_pos
      data.length
    end

    # Writes each argument to the stream. If +$\+ is set, it will be written
    # after all arguments have been written.
    def print(*items)
      items.each { |item| write(item) }
      write($\) if $\
      nil
    end

    # Writes each argument to the stream, appending a newline to any item
    # that does not already end in a newline. Array arguments are flattened.
    def puts(*items)
      items.each do |item|
        if Array === item
          puts(*item)
        else
          write(item)
          write("\n") unless item[-1] == ?\n
        end
      end
      nil
    end

    # Performs an fstat operation on the handle and returns the attribute
    # object (Net::SFTP::Protocol::V01::Attributes, Net::SFTP::Protool::V04::Attributes,
    # or Net::SFTP::Protocol::V06::Attributes, depending on the SFTP protocol
    # version in use).
    def stat
      sftp.fstat!(handle)
    end

    private

      # Fills the buffer. Returns +true+ if it succeeded, and +false+ if
      # EOF was encountered before any data was read.
      def fill
        data = sftp.read!(handle, @real_pos, 8192)

        if data.nil?
          @real_eof = true
          return false
        else
          @real_pos += data.length
          @buffer << data
        end

        !@real_eof
      end
  end

end; end; end
