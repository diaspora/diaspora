module Qrack
	
	class ClientTimeout < Timeout::Error; end
  class ConnectionTimeout < Timeout::Error; end
	
	# Client ancestor class
	class Client
		
		CONNECT_TIMEOUT = 5.0
    RETRY_DELAY     = 10.0

    attr_reader   :status, :host, :vhost, :port, :logging, :spec, :heartbeat
    attr_accessor :channel, :logfile, :exchanges, :queues, :channels, :message_in, :message_out,
 									:connecting

		def initialize(opts = {})
			@host = opts[:host] || 'localhost'
      @user   = opts[:user]  || 'guest'
      @pass   = opts[:pass]  || 'guest'
      @vhost  = opts[:vhost] || '/'
			@logfile = opts[:logfile] || nil
			@logging = opts[:logging] || false
			@ssl = opts[:ssl] || false
      @verify_ssl = opts[:verify_ssl].nil? || opts[:verify_ssl]
      @status = :not_connected
			@frame_max = opts[:frame_max] || 131072
			@channel_max = opts[:channel_max] || 0
			@heartbeat = opts[:heartbeat] || 0
      @connect_timeout = opts[:connect_timeout] || CONNECT_TIMEOUT
			@logger = nil
			create_logger if @logging
			@message_in = false
			@message_out = false
			@connecting = false
			@channels ||= []
			# Create channel 0
      @channel = create_channel()
			@exchanges ||= {}
			@queues ||= {}
		end
		
=begin rdoc

=== DESCRIPTION:

Closes all active communication channels and connection. If an error occurs a
_Bunny_::_ProtocolError_ is raised. If successful, _Client_._status_ is set to <tt>:not_connected</tt>.

==== RETURNS:

<tt>:not_connected</tt> if successful.

=end

		def close
			# Close all active channels
			channels.each do |c|
				c.close if c.open?
			end

			# Close connection to AMQP server
			close_connection

			# Close TCP Socket
      close_socket
    end

		alias stop close
		
		def connected?
			status == :connected
		end
		
		def connecting?
			connecting
		end
		
		def logging=(bool)
			@logging = bool
			create_logger if @logging
		end
		
    def next_payload(options = {})
      next_frame(options).payload
    end

		alias next_method next_payload

    def read(*args)
      send_command(:read, *args)
    end

=begin rdoc

=== DESCRIPTION:

Checks to see whether or not an undeliverable message has been returned as a result of a publish
with the <tt>:immediate</tt> or <tt>:mandatory</tt> options.

==== OPTIONS:

* <tt>:timeout => number of seconds (default = 0.1) - The method will wait for a return
  message until this timeout interval is reached.

==== RETURNS:

<tt>{:header => nil, :payload => :no_return, :return_details => nil}</tt> if message is
not returned before timeout.
<tt>{:header, :return_details, :payload}</tt> if message is returned. <tt>:return_details</tt> is
a hash <tt>{:reply_code, :reply_text, :exchange, :routing_key}</tt>.

=end

		def returned_message(opts = {})
			
			begin		
				frame = next_frame(:timeout => opts[:timeout] || 0.1)
			rescue Qrack::ClientTimeout
				return {:header => nil, :payload => :no_return, :return_details => nil}
			end

			method = frame.payload
			header = next_payload
	
			# If maximum frame size is smaller than message payload body then message
			# will have a message header and several message bodies				
		  msg = ''
			while msg.length < header.size
				msg += next_payload
			end

			# Return the message and related info
			{:header => header, :payload => msg, :return_details => method.arguments}
		end
		
		def switch_channel(chann)
			if (0...channels.size).include? chann
				@channel = channels[chann]
				chann
			else
				raise RuntimeError, "Invalid channel number - #{chann}"
			end
		end
		
		def write(*args)
      send_command(:write, *args)
    end
		
		private
		
		def close_socket(reason=nil)
      # Close the socket. The server is not considered dead.
      @socket.close if @socket and not @socket.closed?
      @socket   = nil
      @status   = :not_connected
    end

    def create_logger
			@logfile ? @logger = Logger.new("#{logfile}") : @logger = Logger.new(STDOUT)
			@logger.level = Logger::INFO
			@logger.datetime_format = "%Y-%m-%d %H:%M:%S"
    end
		
		def send_command(cmd, *args)
      begin
				raise Bunny::ConnectionError, 'No connection - socket has not been created' if !@socket
        @socket.__send__(cmd, *args)
      rescue Errno::EPIPE, IOError => e
        raise Bunny::ServerDownError, e.message
      end
    end

    def socket
      return @socket if @socket and (@status == :connected) and not @socket.closed?

      begin
        # Attempt to connect.
        @socket = timeout(@connect_timeout, ConnectionTimeout) do
          TCPSocket.new(host, port)
        end

        if Socket.constants.include? 'TCP_NODELAY'
          @socket.setsockopt Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1
        end

        if @ssl
          require 'openssl' unless defined? OpenSSL::SSL
          @socket = OpenSSL::SSL::SSLSocket.new(@socket)
          @socket.sync_close = true
          @socket.connect
          @socket.post_connection_check(host) if @verify_ssl
          @socket
        end
      rescue => e
        @status = :not_connected
        raise Bunny::ServerDownError, e.message
      end

      @socket
    end
		
	end
	
end
