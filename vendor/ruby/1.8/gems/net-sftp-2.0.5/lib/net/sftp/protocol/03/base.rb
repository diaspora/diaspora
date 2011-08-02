require 'net/sftp/protocol/02/base'

module Net; module SFTP; module Protocol; module V03

  # Wraps the low-level SFTP calls for version 3 of the SFTP protocol.
  #
  # None of these protocol methods block--all of them return immediately,
  # requiring the SSH event loop to be run while the server response is
  # pending.
  #
  # You will almost certainly never need to use this driver directly. Please
  # see Net::SFTP::Session for the recommended interface.
  class Base < V02::Base

    # Returns the protocol version implemented by this driver. (3, in this
    # case)
    def version
      3
    end

    # Sends a FXP_READLINK packet to the server to request that the target of
    # the given symlink on the remote host (+path+) be returned.
    def readlink(path)
      send_request(FXP_READLINK, :string, path)
    end

    # Sends a FXP_SYMLINK packet to the server to request that a symlink at the
    # given +path+ be created, pointing at +target+..
    def symlink(path, target)
      send_request(FXP_SYMLINK, :string, path, :string, target)
    end

  end

end; end; end; end