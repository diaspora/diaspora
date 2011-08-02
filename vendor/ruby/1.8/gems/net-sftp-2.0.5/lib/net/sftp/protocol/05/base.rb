require 'net/sftp/protocol/04/base'

module Net; module SFTP; module Protocol; module V05

  # Wraps the low-level SFTP calls for version 5 of the SFTP protocol.
  #
  # None of these protocol methods block--all of them return immediately,
  # requiring the SSH event loop to be run while the server response is
  # pending.
  #
  # You will almost certainly never need to use this driver directly. Please
  # see Net::SFTP::Session for the recommended interface.
  class Base < V04::Base
    # Returns the protocol version implemented by this driver. (5, in this
    # case)
    def version
      5
    end

    # Sends a FXP_RENAME packet to the server to request that the file or
    # directory with the given +name+ (must be a full path) be changed to
    # +new_name+ (which must also be a path). The +flags+ parameter must be
    # either +nil+ or 0 (the default), or some combination of the
    # Net::SFTP::Constants::RenameFlags constants.
    def rename(name, new_name, flags=nil)
      send_request(FXP_RENAME, :string, name, :string, new_name, :long, flags || 0)
    end

    # Sends a FXP_OPEN packet to the server and returns the packet identifier.
    # The +flags+ parameter is either an integer (in which case it must be
    # a combination of the IO constants) or a string (in which case it must
    # be one of the mode strings that IO::open accepts). The +options+
    # parameter is a hash that is used to construct a new Attribute object,
    # to pass as part of the FXP_OPEN request.
    def open(path, flags, options)
      flags = normalize_open_flags(flags)

      sftp_flags, desired_access = if flags & (IO::WRONLY | IO::RDWR) != 0
          open = if flags & (IO::CREAT | IO::EXCL) == (IO::CREAT | IO::EXCL)
            FV5::CREATE_NEW
          elsif flags & (IO::CREAT | IO::TRUNC) == (IO::CREAT | IO::TRUNC)
            FV5::CREATE_TRUNCATE
          elsif flags & IO::CREAT == IO::CREAT
            FV5::OPEN_OR_CREATE
          else
            FV5::OPEN_EXISTING
          end
          access = ACE::Mask::WRITE_DATA | ACE::Mask::WRITE_ATTRIBUTES
          access |= ACE::Mask::READ_DATA | ACE::Mask::READ_ATTRIBUTES if (flags & IO::RDWR) == IO::RDWR
          if flags & IO::APPEND == IO::APPEND
            open |= FV5::APPEND_DATA
            access |= ACE::Mask::APPEND_DATA
          end
          [open, access]
        else
          [FV5::OPEN_EXISTING, ACE::Mask::READ_DATA | ACE::Mask::READ_ATTRIBUTES]
        end

      attributes = attribute_factory.new(options)

      send_request(FXP_OPEN, :string, path, :long, desired_access, :long, sftp_flags, :raw, attributes.to_s)
    end

  end

end; end; end; end