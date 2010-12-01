module Bunny
	
=begin rdoc

=== DESCRIPTION:

The Client class provides the major Bunny API methods.

=end

  class Client < Qrack::Client
	
		attr_accessor :ticket

=begin rdoc

=== DESCRIPTION:

Sets up a Bunny::Client object ready for connection to a broker/server. _Client_._status_ is set to
<tt>:not_connected</tt>.

==== OPTIONS:

* <tt>:host => '_hostname_' (default = 'localhost')</tt>
* <tt>:port => _portno_ (default = 5672 or 5671 if :ssl set to true)</tt>
* <tt>:vhost => '_vhostname_' (default = '/')</tt>
* <tt>:user => '_username_' (default = 'guest')</tt>
* <tt>:pass => '_password_' (default = 'guest')</tt>
* <tt>:ssl => true or false (default = false)</tt> - If set to _true_, ssl
  encryption will be used and port will default to 5671.
* <tt>:verify_ssl => true or false (default = true)</tt> - If ssl is enabled,
  this will cause OpenSSL to validate the server certificate unless this
  parameter is set to _false_.
* <tt>:logfile => '_logfilepath_' (default = nil)</tt>
* <tt>:logging => true or false (_default_)</tt> - If set to _true_, session information is sent
  to STDOUT if <tt>:logfile</tt> has not been specified. Otherwise, session information is written to
  <tt>:logfile</tt>.
* <tt>:insist => true or false (_default_)</tt> - In a configuration with multiple load-sharing
  servers, the server may respond to a Connection::Open method with a Connection::Redirect. The insist
  option, if set to _true_, tells the server that the client is insisting on a connection to the
  specified server.
* <tt>:frame_max => maximum frame size in bytes (default = 131072)</tt>
* <tt>:channel_max => maximum number of channels (default = 0 no maximum)</tt>
* <tt>:heartbeat => number of seconds (default = 0 no heartbeat)</tt>
* <tt>:connect_timeout => number of seconds before Qrack::ConnectionTimeout is raised (default = 5)</tt>

=end

    def initialize(opts = {})
			super
			@spec = '0-8'
			@port = opts[:port] || (opts[:ssl] ? Qrack::Protocol::SSL_PORT : Qrack::Protocol::PORT)
      @insist = opts[:insist]
    end

=begin rdoc

=== DESCRIPTION:

Checks response from AMQP methods and takes appropriate action

=end

		def check_response(received_method, expected_method, err_msg, err_class = Bunny::ProtocolError)
			case
				when received_method.is_a?(Qrack::Protocol::Connection::Close)
					# Clean up the socket
					close_socket
					
					raise Bunny::ForcedConnectionCloseError,
						"Error Reply Code: #{received_method.reply_code}\nError Reply Text: #{received_method.reply_text}"
						
				when received_method.is_a?(Qrack::Protocol::Channel::Close)
					# Clean up the channel
					channel.active = false

					raise Bunny::ForcedChannelCloseError,
						"Error Reply Code: #{received_method.reply_code}\nError Reply Text: #{received_method.reply_text}"
						
				when !received_method.is_a?(expected_method)
					raise err_class, err_msg
					
				else
					:response_ok
			end
		end

		def close_connection
			# Set client channel to zero
      switch_channel(0)
		
			send_frame(
	      Qrack::Protocol::Connection::Close.new(:reply_code => 200, :reply_text => 'Goodbye', :class_id => 0, :method_id => 0)
	    )
	
			method = next_method
			
			check_response(method, Qrack::Protocol::Connection::CloseOk, "Error closing connection")
	    
    end

		def create_channel
			channels.each do |c|
				return c if (!c.open? and c.number != 0)
			end
			# If no channel to re-use instantiate new one
			Bunny::Channel.new(self)
		end

=begin rdoc

=== DESCRIPTION:

Declares an exchange to the broker/server. If the exchange does not exist, a new one is created
using the arguments passed in. If the exchange already exists, the existing object is returned.
If an error occurs a _Bunny_::_ProtocolError_ is raised.

==== OPTIONS:

* <tt>:type => one of :direct (_default_), :fanout, :topic, :headers</tt>
* <tt>:passive => true or false</tt> - If set to _true_, the server will not create the exchange.
  The client can use this to check whether an exchange exists without modifying the server state.
* <tt>:durable => true or false (_default_)</tt> - If set to _true_ when creating a new exchange, the exchange
  will be marked as durable. Durable exchanges remain active when a server restarts. Non-durable
  exchanges (transient exchanges) are purged if/when a server restarts.
* <tt>:auto_delete => true or false (_default_)</tt> - If set to _true_, the exchange is deleted
  when all queues have finished using it.
* <tt>:nowait => true or false (_default_)</tt> - Ignored by Bunny, always _false_.

==== RETURNS:

Exchange

=end

		def exchange(name, opts = {})
      exchanges[name] || Bunny::Exchange.new(self, name, opts)
		end
		
		def init_connection
			write(Qrack::Protocol::HEADER)
      write([1, 1, Qrack::Protocol::VERSION_MAJOR, Qrack::Protocol::VERSION_MINOR].pack('C4'))

			frame = next_frame
			if frame.nil? or !frame.payload.is_a?(Qrack::Protocol::Connection::Start)
				raise Bunny::ProtocolError, 'Connection initiation failed'
			end
		end
		
		def next_frame(opts = {})
      frame = nil
			
			case
				when channel.frame_buffer.size > 0
					frame = channel.frame_buffer.shift
				when opts.has_key?(:timeout)
	        Timeout::timeout(opts[:timeout], Qrack::ClientTimeout) do
	          frame = Qrack::Transport::Frame.parse(buffer)
	        end
	      else
	        frame = Qrack::Transport::Frame.parse(buffer)
      end
			
			@logger.info("received") { frame } if @logging
						
			raise Bunny::ConnectionError, 'No connection to server' if (frame.nil? and !connecting?)
			
			# Monitor server activity and discard heartbeats
			@message_in = true
			
			case
				when frame.is_a?(Qrack::Transport::Heartbeat)
					next_frame(opts)
				when frame.nil?
					frame
				when ((frame.channel != channel.number) and (frame.channel != 0))
					channel.frame_buffer << frame
					next_frame(opts)
				else
					frame
			end
			
    end

		def open_connection
			send_frame(
        Qrack::Protocol::Connection::StartOk.new(
          {:platform => 'Ruby', :product => 'Bunny', :information => 'http://github.com/celldee/bunny', :version => VERSION},
          'AMQPLAIN',
          {:LOGIN => @user, :PASSWORD => @pass},
          'en_US'
        )
      )

      frame = next_frame
			raise Bunny::ProtocolError, "Connection failed - user: #{@user}" if frame.nil?
			
			method = frame.payload

      if method.is_a?(Qrack::Protocol::Connection::Tune)
        send_frame(
          Qrack::Protocol::Connection::TuneOk.new( :channel_max => @channel_max, :frame_max => @frame_max, :heartbeat => @heartbeat)
        )
      end

      send_frame(
        Qrack::Protocol::Connection::Open.new(:virtual_host => @vhost, :capabilities => '', :insist => @insist)
      )

      case method = next_method
      when Qrack::Protocol::Connection::OpenOk
        :ok
      when Qrack::Protocol::Connection::Redirect
				raise Bunny::ConnectionError, "Cannot connect to the specified server - host: #{@host}, port: #{@port}" if @insist
				
        @host, @port = method.host.split(':')
        close_socket
      else
        raise Bunny::ProtocolError, 'Cannot open connection'
      end
		end

=begin rdoc

=== DESCRIPTION:

Requests a specific quality of service. The QoS can be specified for the current channel
or for all channels on the connection. The particular properties and semantics of a QoS
method always depend on the content class semantics. Though the QoS method could in principle
apply to both peers, it is currently meaningful only for the server.

==== Options:

* <tt>:prefetch_size => size in no. of octets (default = 0)</tt> - The client can request that
messages be sent in advance so that when the client finishes processing a message, the following
message is already held locally, rather than needing to be sent down the channel. Prefetching gives
a performance improvement. This field specifies the prefetch window size in octets. The server
will send a message in advance if it is equal to or smaller in size than the available prefetch
size (and also falls into other prefetch limits). May be set to zero, meaning "no specific limit",
although other prefetch limits may still apply. The prefetch-size is ignored if the no-ack option
is set.
* <tt>:prefetch_count => no. messages (default = 1)</tt> - Specifies a prefetch window in terms
of whole messages. This field may be used in combination with the prefetch-size field; a message
will only be sent in advance if both prefetch windows (and those at the channel and connection level)
allow it. The prefetch-count is ignored if the no-ack option is set.
* <tt>:global => true or false (_default_)</tt> - By default the QoS settings apply to the current channel only. If set to
true, they are applied to the entire connection.

==== RETURNS:

<tt>:qos_ok</tt> if successful.

=end

		def qos(opts = {})

      send_frame(
        Qrack::Protocol::Basic::Qos.new({ :prefetch_size => 0, :prefetch_count => 1, :global => false }.merge(opts))
      )

			method = next_method
			
			check_response(method, Qrack::Protocol::Basic::QosOk, "Error specifying Quality of Service")

      # return confirmation
      :qos_ok
    end

=begin rdoc

=== DESCRIPTION:

Declares a queue to the broker/server. If the queue does not exist, a new one is created
using the arguments passed in. If the queue already exists, a reference to it is created, provided
that the arguments passed in do not conflict with the existing attributes of the queue. If an error
occurs a _Bunny_::_ProtocolError_ is raised.

==== OPTIONS:

* <tt>:passive => true or false (_default_)</tt> - If set to _true_, the server will not create
  the queue. The client can use this to check whether a queue exists without modifying the server
  state.
* <tt>:durable => true or false (_default_)</tt> - 	If set to _true_ when creating a new queue, the
  queue will be marked as durable. Durable queues remain active when a server restarts. Non-durable
  queues (transient queues) are purged if/when a server restarts. Note that durable queues do not
  necessarily hold persistent messages, although it does not make sense to send persistent messages
  to a transient queue.
* <tt>:exclusive => true or false (_default_)</tt> - If set to _true_, requests an exclusive queue.
  Exclusive queues may only be consumed from by the current connection. Setting the 'exclusive'
  flag always implies 'auto-delete'.
* <tt>:auto_delete => true or false (_default_)</tt> - 	If set to _true_, the queue is deleted
  when all consumers have finished	using it. Last consumer can be cancelled either explicitly
  or because its channel is closed. If there has never been a consumer on the queue, it is not
  deleted.
* <tt>:nowait => true or false (_default_)</tt> - Ignored by Bunny, always _false_.

==== RETURNS:

Queue

=end
		
		def queue(name = nil, opts = {})
      if name.is_a?(Hash)
        opts = name
        name = nil
      end

      # Queue is responsible for placing itself in the list of queues
      queues[name] || Bunny::Queue.new(self, name, opts)
	  end

=begin rdoc

=== DESCRIPTION:

Asks the broker to redeliver all unacknowledged messages on a specified channel. Zero or
more messages may be redelivered.

==== Options:

* <tt>:requeue => true or false (_default_)</tt> - If set to _false_, the message will be
redelivered to the original recipient. If set to _true_, the server will attempt to requeue
the message, potentially then delivering it to an alternative subscriber.

=end

		def recover(opts = {})

	    send_frame(
	      Qrack::Protocol::Basic::Recover.new({ :requeue => false }.merge(opts))
	    )

	  end
	
		def request_access
			send_frame(
        Qrack::Protocol::Access::Request.new(:realm => '/data', :read => true, :write => true, :active => true, :passive => true)
      )

      method = next_method
			
			check_response(method, Qrack::Protocol::Access::RequestOk, "Access denied")
      
      self.ticket = method.ticket
		end
	
		def send_frame(*args)
      args.each do |data|
        data.ticket  = ticket if ticket and data.respond_to?(:ticket=)
        data         = data.to_frame(channel.number) unless data.is_a?(Qrack::Transport::Frame)
        data.channel = channel.number

        @logger.info("send") { data } if @logging
        write(data.to_s)

				# Monitor client activity for heartbeat purposes
				@message_out = true
      end

      nil
    end
		
		def send_heartbeat
			# Create a new heartbeat frame
			hb = Qrack::Transport::Heartbeat.new('')		
			# Channel 0 must be used
			switch_channel(0) if @channel.number > 0			
			# Send the heartbeat to server
			send_frame(hb)
		end

=begin rdoc

=== DESCRIPTION:

Opens a communication channel and starts a connection. If an error occurs, a
_Bunny_::_ProtocolError_ is raised. If successful, _Client_._status_ is set to <tt>:connected</tt>.

==== RETURNS:

<tt>:connected</tt> if successful.

=end
		
		def start_session
			@connecting = true
			
      loop do
				# Create/get socket
				socket
				
				# Initiate connection
				init_connection

				# Open connection
				break if open_connection == :ok
      end

			# Open another channel because channel zero is used for specific purposes
			c = create_channel()
			c.open
			
			# Get access ticket
			request_access

			@connecting = false
			
			# return status
			@status = :connected
    end

		alias start start_session
		
=begin rdoc

=== DESCRIPTION:
This method commits all messages published and acknowledged in
the current transaction. A new transaction starts immediately
after a commit.

==== RETURNS:

<tt>:commit_ok</tt> if successful.

=end

		def tx_commit
			send_frame(Qrack::Protocol::Tx::Commit.new())
			
			method = next_method
			
			check_response(method, Qrack::Protocol::Tx::CommitOk, "Error commiting transaction")

			# return confirmation
			:commit_ok
		end
		
=begin rdoc

=== DESCRIPTION:
This method abandons all messages published and acknowledged in
the current transaction. A new transaction starts immediately
after a rollback.

==== RETURNS:

<tt>:rollback_ok</tt> if successful.

=end

		def tx_rollback
			send_frame(Qrack::Protocol::Tx::Rollback.new())

			method = next_method
			
			check_response(method, Qrack::Protocol::Tx::RollbackOk, "Error rolling back transaction")

			# return confirmation
			:rollback_ok
		end

=begin rdoc

=== DESCRIPTION:
This method sets the channel to use standard transactions. The
client must use this method at least once on a channel before
using the Commit or Rollback methods.

==== RETURNS:

<tt>:select_ok</tt> if successful.

=end

		def tx_select
			send_frame(Qrack::Protocol::Tx::Select.new())

			method = next_method
			
			check_response(method, Qrack::Protocol::Tx::SelectOk, "Error initiating transactions for current channel")

			# return confirmation
			:select_ok
		end

  private

    def buffer
      @buffer ||= Qrack::Transport::Buffer.new(self)
    end

  end
end
