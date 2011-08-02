require 'net/sftp/protocol/01/base'
require 'net/sftp/protocol/02/base'
require 'net/sftp/protocol/03/base'
require 'net/sftp/protocol/04/base'
require 'net/sftp/protocol/05/base'
require 'net/sftp/protocol/06/base'

module Net; module SFTP

  # The Protocol module contains the definitions for all supported SFTP
  # protocol versions.
  module Protocol

    # Instantiates and returns a new protocol driver instance for the given
    # protocol version. +session+ must be a valid SFTP session object, and
    # +version+ must be an integer. If an unsupported version is given,
    # an exception will be raised.
    def self.load(session, version)
      case version
      when 1 then V01::Base.new(session)
      when 2 then V02::Base.new(session)
      when 3 then V03::Base.new(session)
      when 4 then V04::Base.new(session)
      when 5 then V05::Base.new(session)
      when 6 then V06::Base.new(session)
      else raise NotImplementedError, "unsupported SFTP version #{version.inspect}"
      end
    end

  end

end; end