require 'net/ssh/loggable'
require 'net/sftp/constants'

module Net; module SFTP; module Protocol

  # The abstract superclass of the specific implementations for each supported
  # SFTP protocol version. It implements general packet parsing logic, and
  # provides a way for subclasses to send requests.
  class Base
    include Net::SSH::Loggable
    include Net::SFTP::Constants
    include Net::SFTP::Constants::PacketTypes

    # The SFTP session object that acts as client to this protocol instance
    attr_reader :session

    # Create a new instance of a protocol driver, servicing the given session.
    def initialize(session)
      @session = session
      self.logger = session.logger
      @request_id_counter = -1
    end

    # Attept to parse the given packet. If the packet is of an unsupported
    # type, an exception will be raised. Returns the parsed data as a hash
    # (the keys in the hash are packet-type specific).
    def parse(packet)
      case packet.type
      when FXP_STATUS then parse_status_packet(packet)
      when FXP_HANDLE then parse_handle_packet(packet)
      when FXP_DATA   then parse_data_packet(packet)
      when FXP_NAME   then parse_name_packet(packet)
      when FXP_ATTRS  then parse_attrs_packet(packet)
      else raise NotImplementedError, "unknown packet type: #{packet.type}"
      end
    end

    private

      # Send a new packet of the given type, and with the given data arguments.
      # A new request identifier will be allocated to this request, and will
      # be returned.
      def send_request(type, *args)
        @request_id_counter += 1
        session.send_packet(type, :long, @request_id_counter, *args)
        return @request_id_counter
      end
  end

end; end; end