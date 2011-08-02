require 'net/sftp/constants'
require 'net/sftp/response'

module Net; module SFTP

  # Encapsulates a single active SFTP request. This is instantiated
  # automatically by the Net::SFTP::Session class when an operation is
  # executed.
  #
  #   request = sftp.open("/path/to/file")
  #   puts request.pending? #-> true
  #   request.wait
  #   puts request.pending? #-> false
  #   result = request.response
  class Request
    include Constants::PacketTypes

    # The Net::SFTP session object that is servicing this request
    attr_reader :session

    # The SFTP packet identifier for this request
    attr_reader :id

    # The type of this request (e.g., :open, :symlink, etc.)
    attr_reader :type

    # The callback (if any) associated with this request. When the response
    # is recieved for this request, the callback will be invoked.
    attr_reader :callback

    # The hash of properties associated with this request. Properties allow
    # programmers to associate arbitrary data with a request, making state
    # machines richer.
    attr_reader :properties

    # The response that was received for this request (see Net::SFTP::Response)
    attr_reader :response

    # Instantiate a new Request object, serviced by the given +session+, and
    # being of the given +type+. The +id+ is the packet identifier for this
    # request.
    def initialize(session, type, id, &callback) #:nodoc:
      @session, @id, @type, @callback = session, id, type, callback
      @response = nil
      @properties = {}
    end

    # Returns the value of property with the given +key+. If +key+ is not a
    # symbol, it will be converted to a symbol before lookup.
    def [](key)
      properties[key.to_sym]
    end

    # Sets the value of the property with name +key+ to +value+. If +key+ is
    # not a symbol, it will be converted to a symbol before lookup.
    def []=(key, value)
      properties[key.to_sym] = value
    end

    # Returns +true+ if the request is still waiting for a response from the
    # server, and +false+ otherwise. The SSH event loop must be run in order
    # for a request to be processed; see #wait.
    def pending?
      session.pending_requests.key?(id)
    end

    # Waits (blocks) until the server responds to this packet. If prior
    # SFTP packets were also pending, they will be processed as well (since
    # SFTP packets are processed in the order in which they are received by
    # the server). Returns the request object itself.
    def wait
      session.loop { pending? }
      self
    end

    public # but not "published". Internal use only

      # When the server responds to this request, the packet is passed to
      # this method, which parses the packet and builds a Net::SFTP::Response
      # object to encapsulate it. If a #callback has been provided for this
      # request, the callback is invoked with the new response object.
      def respond_to(packet) #:nodoc:
        data = session.protocol.parse(packet)
        data[:type] = packet.type
        @response = Response.new(self, data)

        callback.call(@response) if callback
      end
  end

end; end