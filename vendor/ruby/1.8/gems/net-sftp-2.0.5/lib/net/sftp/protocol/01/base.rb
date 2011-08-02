require 'net/ssh/loggable'
require 'net/sftp/constants'
require 'net/sftp/packet'
require 'net/sftp/protocol/base'
require 'net/sftp/protocol/01/attributes'
require 'net/sftp/protocol/01/name'

module Net; module SFTP; module Protocol; module V01

  # Wraps the low-level SFTP calls for version 1 of the SFTP protocol. Also
  # implements the packet parsing as defined by version 1 of the protocol.
  #
  # None of these protocol methods block--all of them return immediately,
  # requiring the SSH event loop to be run while the server response is
  # pending.
  #
  # You will almost certainly never need to use this driver directly. Please
  # see Net::SFTP::Session for the recommended interface.
  class Base < Protocol::Base
    include Net::SFTP::Constants::OpenFlags

    # Returns the protocol version implemented by this driver. (1, in this
    # case)
    def version
      1
    end

    # Parses the given FXP_HANDLE packet and returns a hash with one key,
    # :handle, which references the handle.
    def parse_handle_packet(packet)
      { :handle => packet.read_string }
    end

    # Parses the given FXP_STATUS packet and returns a hash with one key,
    # :code, which references the status code returned by the server.
    def parse_status_packet(packet)
      { :code => packet.read_long }
    end

    # Parses the given FXP_DATA packet and returns a hash with one key,
    # :data, which references the data returned in the packet.
    def parse_data_packet(packet)
      { :data => packet.read_string }
    end

    # Parses the given FXP_ATTRS packet and returns a hash with one key,
    # :attrs, which references an Attributes object.
    def parse_attrs_packet(packet)
      { :attrs => attribute_factory.from_buffer(packet) }
    end

    # Parses the given FXP_NAME packet and returns a hash with one key, :names,
    # which references an array of Name objects.
    def parse_name_packet(packet)
      names = []

      packet.read_long.times do
        filename = packet.read_string
        longname = packet.read_string
        attrs    = attribute_factory.from_buffer(packet)
        names   << name_factory.new(filename, longname, attrs)
      end

      { :names => names }
    end

    # Sends a FXP_OPEN packet to the server and returns the packet identifier.
    # The +flags+ parameter is either an integer (in which case it must be
    # a combination of the IO constants) or a string (in which case it must
    # be one of the mode strings that IO::open accepts). The +options+
    # parameter is a hash that is used to construct a new Attribute object,
    # to pass as part of the FXP_OPEN request.
    def open(path, flags, options)
      flags = normalize_open_flags(flags)

      if flags & (IO::WRONLY | IO::RDWR) != 0
        sftp_flags = FV1::WRITE
        sftp_flags |= FV1::READ if flags & IO::RDWR != 0
        sftp_flags |= FV1::APPEND if flags & IO::APPEND != 0
      else
        sftp_flags = FV1::READ
      end

      sftp_flags |= FV1::CREAT if flags & IO::CREAT != 0
      sftp_flags |= FV1::TRUNC if flags & IO::TRUNC != 0
      sftp_flags |= FV1::EXCL  if flags & IO::EXCL  != 0

      attributes = attribute_factory.new(options)

      send_request(FXP_OPEN, :string, path, :long, sftp_flags, :raw, attributes.to_s)
    end

    # Sends a FXP_CLOSE packet to the server for the given +handle+ (such as
    # would be returned via a FXP_HANDLE packet). Returns the new packet id.
    def close(handle)
      send_request(FXP_CLOSE, :string, handle)
    end

    # Sends a FXP_READ packet to the server, requesting that +length+ bytes
    # be read from the file identified by +handle+, starting at +offset+ bytes
    # within the file. The handle must be one that was returned via a
    # FXP_HANDLE packet. Returns the new packet id.
    def read(handle, offset, length)
      send_request(FXP_READ, :string, handle, :int64, offset, :long, length)
    end

    # Sends a FXP_WRITE packet to the server, requesting that +data+ (a string),
    # be written to the file identified by +handle+, starting at +offset+ bytes
    # from the beginning of the file. The handle must be one that was returned
    # via a FXP_HANDLE packet. Returns the new packet id.
    def write(handle, offset, data)
      send_request(FXP_WRITE, :string, handle, :int64, offset, :string, data)
    end

    # Sends a FXP_LSTAT packet to the server, requesting a FXP_ATTR response
    # for the file at the given remote +path+ (a string). The +flags+ parameter
    # is ignored in this version of the protocol. #lstat will not follow
    # symbolic links; see #stat for a version that will.
    def lstat(path, flags=nil)
      send_request(FXP_LSTAT, :string, path)
    end

    # Sends a FXP_FSTAT packet to the server, requesting a FXP_ATTR response
    # for the file represented by the given +handle+ (which must have been
    # obtained from a FXP_HANDLE packet). The +flags+ parameter is ignored in
    # this version of the protocol.
    def fstat(handle, flags=nil)
      send_request(FXP_FSTAT, :string, handle)
    end

    # Sends a FXP_SETSTAT packet to the server, to update the attributes for
    # the file at the given remote +path+ (a string). The +attrs+ parameter is
    # a hash that defines the attributes to set.
    def setstat(path, attrs)
      send_request(FXP_SETSTAT, :string, path, :raw, attribute_factory.new(attrs).to_s)
    end

    # Sends a FXP_FSETSTAT packet to the server, to update the attributes for
    # the file represented by the given +handle+ (which must have been obtained
    # from a FXP_HANDLE packet). The +attrs+ parameter is a hash that defines
    # the attributes to set.
    def fsetstat(handle, attrs)
      send_request(FXP_FSETSTAT, :string, handle, :raw, attribute_factory.new(attrs).to_s)
    end

    # Sends a FXP_OPENDIR packet to the server, to request a handle for
    # manipulating the directory at the given remote +path+.
    def opendir(path)
      send_request(FXP_OPENDIR, :string, path)
    end

    # Sends a FXP_READDIR packet to the server, to request a batch of
    # directory name entries in the directory identified by +handle+ (which
    # must have been obtained via a FXP_OPENDIR request).
    def readdir(handle)
      send_request(FXP_READDIR, :string, handle)
    end

    # Sends a FXP_REMOTE packet to the server, to request that the given
    # file be deleted from the remote server.
    def remove(filename)
      send_request(FXP_REMOVE, :string, filename)
    end

    # Sends a FXP_MKDIR packet to the server, to request that a new directory
    # at +path+ on the remote server be created, and with +attrs+ (a hash)
    # describing the attributes of the new directory.
    def mkdir(path, attrs)
      send_request(FXP_MKDIR, :string, path, :raw, attribute_factory.new(attrs).to_s)
    end

    # Sends a FXP_RMDIR packet to the server, to request that the directory
    # at +path+ on the remote server be deleted.
    def rmdir(path)
      send_request(FXP_RMDIR, :string, path)
    end

    # Sends a FXP_REALPATH packet to the server, to request that the given
    # +path+ be canonicalized, taking into account path segments like "..".
    def realpath(path)
      send_request(FXP_REALPATH, :string, path)
    end

    # Sends a FXP_STAT packet to the server, requesting a FXP_ATTR response
    # for the file at the given remote +path+ (a string). The +flags+ parameter
    # is ignored in this version of the protocol. #stat will follow
    # symbolic links; see #lstat for a version that will not.
    def stat(path, flags=nil)
      send_request(FXP_STAT, :string, path)
    end

    # Not implemented in version 1 of the SFTP protocol. Raises a
    # NotImplementedError if called.
    def rename(name, new_name, flags=nil)
      not_implemented! :rename
    end

    # Not implemented in version 1 of the SFTP protocol. Raises a
    # NotImplementedError if called.
    def readlink(path)
      not_implemented! :readlink
    end

    # Not implemented in version 1 of the SFTP protocol. Raises a
    # NotImplementedError if called.
    def symlink(path, target)
      not_implemented! :symlink
    end

    # Not implemented in version 1 of the SFTP protocol. Raises a
    # NotImplementedError if called.
    def link(*args)
      not_implemented! :link
    end

    # Not implemented in version 1 of the SFTP protocol. Raises a
    # NotImplementedError if called.
    def block(handle, offset, length, mask)
      not_implemented! :block
    end

    # Not implemented in version 1 of the SFTP protocol. Raises a
    # NotImplementedError if called.
    def unblock(handle, offset, length)
      not_implemented! :unblock
    end

    protected

      # A helper method for implementing wrappers for operations that are
      # not implemented by the current SFTP protocol version. Simply raises
      # NotImplementedError with a message based on the given operation name.
      def not_implemented!(operation)
        raise NotImplementedError, "the #{operation} operation is not available in the version of the SFTP protocol supported by your server"
      end

      # Normalizes the given flags parameter, converting it into a combination
      # of IO constants.
      def normalize_open_flags(flags)
        if String === flags
          case flags.tr("b", "")
          when "r"  then IO::RDONLY
          when "r+" then IO::RDWR
          when "w"  then IO::WRONLY | IO::TRUNC | IO::CREAT
          when "w+" then IO::RDWR | IO::TRUNC | IO::CREAT
          when "a"  then IO::APPEND | IO::CREAT | IO::WRONLY
          when "a+" then IO::APPEND | IO::CREAT | IO::RDWR
          else raise ArgumentError, "unsupported flags: #{flags.inspect}"
          end
        else
          flags.to_i
        end
      end

      # Returns the Attributes class used by this version of the protocol
      # (Net::SFTP::Protocol::V01::Attributes, in this case)
      def attribute_factory
        V01::Attributes
      end

      # Returns the Name class used by this version of the protocol
      # (Net::SFTP::Protocol::V01::Name, in this case)
      def name_factory
        V01::Name
      end
  end

end; end; end; end