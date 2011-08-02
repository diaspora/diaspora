require 'net/sftp/protocol/05/base'
require 'net/sftp/protocol/06/attributes'

module Net; module SFTP; module Protocol; module V06

  # Wraps the low-level SFTP calls for version 6 of the SFTP protocol.
  #
  # None of these protocol methods block--all of them return immediately,
  # requiring the SSH event loop to be run while the server response is
  # pending.
  #
  # You will almost certainly never need to use this driver directly. Please
  # see Net::SFTP::Session for the recommended interface.
  class Base < V05::Base

    # Returns the protocol version implemented by this driver. (6, in this
    # case)
    def version
      6
    end

    # Sends a FXP_LINK packet to the server to request that a link be created
    # at +new_link_path+, pointing to +existing_path+. If +symlink+ is true, a
    # symbolic link will be created; otherwise a hard link will be created.
    def link(new_link_path, existing_path, symlink)
      send_request(FXP_LINK, :string, new_link_path, :string, existing_path, :bool, symlink)
    end

    # Provided for backwards compatibility; v6 of the SFTP protocol removes the
    # older FXP_SYMLINK packet type, so this method simply calls the #link
    # method.
    def symlink(path, target)
      link(path, target, true)
    end

    # Sends a FXP_BLOCK packet to the server to request that a byte-range lock
    # be obtained on the given +handle+, for the given byte +offset+ and
    # +length+. The +mask+ parameter is a bitfield indicating what kind of
    # lock to acquire, and must be a combination of one or more of the
    # Net::SFTP::Constants::LockTypes constants.
    def block(handle, offset, length, mask)
      send_request(FXP_BLOCK, :string, handle, :int64, offset, :int64, length, :long, mask)
    end

    # Sends a FXP_UNBLOCK packet to the server to request that a previously
    # acquired byte-range lock be released on the given +handle+, for the
    # given byte +offset+ and +length+. The +handle+, +offset+, and +length+
    # must all exactly match the parameters that were given when the lock was
    # originally acquired (see #block).
    def unblock(handle, offset, length)
      send_request(FXP_UNBLOCK, :string, handle, :int64, offset, :int64, length)
    end

    protected

      # Returns the Attributes class used by this version of the protocol
      # (Net::SFTP::Protocol::V06::Attributes, in this case)
      def attribute_factory
        V06::Attributes
      end
  end

end; end; end; end