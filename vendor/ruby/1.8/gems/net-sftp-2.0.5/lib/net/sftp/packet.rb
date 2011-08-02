require 'net/ssh/buffer'

module Net; module SFTP

  # A specialization of the Net::SSH::Buffer class, which simply auto-reads
  # the type byte from the front of every packet it represents.
  class Packet < Net::SSH::Buffer
    # The (intger) type of this packet. See Net::SFTP::Constants for all
    # possible packet types.
    attr_reader :type

    # Create a new Packet object that wraps the given +data+ (which should be
    # a String). The first byte of the data will be consumed automatically and
    # interpreted as the #type of this packet.
    def initialize(data)
      super
      @type = read_byte
    end
  end

end; end