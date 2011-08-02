require 'net/sftp/protocol/01/base'

module Net; module SFTP; module Protocol; module V02

  # Wraps the low-level SFTP calls for version 2 of the SFTP protocol.
  #
  # None of these protocol methods block--all of them return immediately,
  # requiring the SSH event loop to be run while the server response is
  # pending.
  #
  # You will almost certainly never need to use this driver directly. Please
  # see Net::SFTP::Session for the recommended interface.
  class Base < V01::Base

    # Returns the protocol version implemented by this driver. (2, in this
    # case)
    def version
      2
    end

    # Sends a FXP_RENAME packet to the server to request that the file or
    # directory with the given +name+ (must be a full path) be changed to
    # +new_name+ (which must also be a path). The +flags+ parameter is
    # ignored in this version of the protocol.
    def rename(name, new_name, flags=nil)
      send_request(FXP_RENAME, :string, name, :string, new_name)
    end

  end

end; end; end; end
