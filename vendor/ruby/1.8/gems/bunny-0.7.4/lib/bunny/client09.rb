# encoding: utf-8

module Bunny

  # The Client class provides the major Bunny API methods.
  class Client09 < Qrack::Client

    # Sets up a Bunny::Client object ready for connection to a broker.
    # {Client.status} is set to @:not_connected@.
    #
    # @option opts [String] :host ("localhost")
    # @option opts [Integer] :port (5672 or 5671 if :ssl set to true)
    # @option opts [String] :vhost ("/")
    # @option opts [String] :user ("guest")
    # @option opts [String] :pass ("guest")
    # @option opts [Boolean] :ssl (false)
    #   If set to @true@, ssl encryption will be used and port will default to 5671.
    # @option opts [Boolean] :verify_ssl (true)
    #   If ssl is enabled, this will cause OpenSSL to validate
    #   the server certificate unless this parameter is set to @false@.
    # @option opts [String] :logfile (nil)
    # @option opts [Boolean] :logging (false)
    #   If set to @true@, session information is sent to STDOUT if @:logfile@
    #   has not been specified. Otherwise, session information is written to @:logfile@.
    # @option opts [Integer] :frame_max (131072)
    #   Maximum frame size in bytes.
    # @option opts [Integer] :channel_max (0)
    #   Maximum number of channels. Defaults to 0 which means no maximum.
    # @option opts [Integer] :heartbeat (0)
    #   Number of seconds. Defaults to 0 which means no heartbeat.
    # @option opts [Integer] :connect_timeout (5)
    #   Number of seconds before {Qrack::ConnectionTimeout} is raised.@
    def initialize(connection_string_or_opts = Hash.new, opts = Hash.new)
      super
      @spec = '0-9-1'
      @port = self.__opts__[:port] || (self.__opts__[:ssl] ? Qrack::Protocol09::SSL_PORT : Qrack::Protocol09::PORT)
    end

    # Checks response from AMQP methods and takes appropriate action
    def check_response(received_method, expected_method, err_msg, err_class = Bunny::ProtocolError)
      case
      when received_method.is_a?(Qrack::Protocol09::Connection::Close)
        # Clean up the socket
        close_socket

        raise Bunny::ForcedConnectionCloseError, "Error Reply Code: #{received_method.reply_code}\nError Reply Text: #{received_method.reply_text}"

      when received_method.is_a?(Qrack::Protocol09::Channel::Close)
        # Clean up the channel
        channel.active = false

        raise Bunny::ForcedChannelCloseError, "Error Reply Code: #{received_method.reply_code}\nError Reply Text: #{received_method.reply_text}"

      when !received_method.is_a?(expected_method)
        raise err_class, err_msg

      else
        :response_ok
      end
    end

    def close_connection
      # Set client channel to zero
      switch_channel(0)

      send_frame(Qrack::Protocol09::Connection::Close.new(:reply_code => 200, :reply_text => 'Goodbye', :class_id => 0, :method_id => 0))

      method = next_method

      check_response(method, Qrack::Protocol09::Connection::CloseOk, "Error closing connection")

    end

    def create_channel
      channels.each do |c|
        return c if (!c.open? and c.number != 0)
      end
      # If no channel to re-use instantiate new one
      Bunny::Channel09.new(self)
    end

    # Declares an exchange to the broker/server. If the exchange does not exist, a new one is created
    # using the arguments passed in. If the exchange already exists, a reference to it is created, provided
    # that the arguments passed in do not conflict with the existing attributes of the exchange. If an error
    # occurs a _Bunny_::_ProtocolError_ is raised.
    #
    # @option opts [Symbol] :type (:direct)
    #   One of :direct@, @:fanout@, @:topic@, or @:headers@.
    #
    # @option opts [Boolean] :passive
    #   If set to @true@, the server will not create the exchange.
    #   The client can use this to check whether an exchange exists without modifying the server state.
    #
    # @option opts [Boolean] :durable (false)
    #   If set to @true@ when creating a new exchange, the exchange
    #   will be marked as durable. Durable exchanges remain active
    #   when a server restarts. Non-durable exchanges (transient exchanges)
    #   are purged if/when a server restarts.
    #
    # @option opts [Boolean] :auto_delete (false)
    #   If set to @true@, the exchange is deleted when all queues have finished using it.
    #
    # @option opts [Boolean] :nowait (false)
    #   Ignored by Bunny, always @false@.
    #
    # @return [Bunny::Exchange09]
    def exchange(name, opts = {})
      exchanges[name] || Bunny::Exchange09.new(self, name, opts)
    end

    def init_connection
      write(Qrack::Protocol09::HEADER)
      write([0, Qrack::Protocol09::VERSION_MAJOR, Qrack::Protocol09::VERSION_MINOR, Qrack::Protocol09::REVISION].pack('C4'))

      frame = next_frame
      if frame.nil? or !frame.payload.is_a?(Qrack::Protocol09::Connection::Start)
        raise Bunny::ProtocolError, 'Connection initiation failed'
      end
    end

    def next_frame(opts = {})
      frame = nil

      case
      when channel.frame_buffer.size > 0
        frame = channel.frame_buffer.shift
      when (timeout = opts[:timeout]) && timeout > 0
        Bunny::Timer::timeout(timeout, Qrack::FrameTimeout) do
          frame = Qrack::Transport09::Frame.parse(buffer)
        end
      else
        frame = Qrack::Transport09::Frame.parse(buffer)
      end

      @logger.info("received") { frame } if @logging

      raise Bunny::ConnectionError, 'No connection to server' if (frame.nil? and !connecting?)

      # Monitor server activity and discard heartbeats
      @message_in = true

      case
      when frame.is_a?(Qrack::Transport09::Heartbeat)
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
      client_props = { :platform => 'Ruby', :product => 'Bunny', :information => 'http://github.com/ruby-amqp/bunny', :version => VERSION }
      start_opts = {
        :client_properties => client_props,
        :mechanism => 'PLAIN',
        :response => "\0" + @user + "\0" + @pass,
        :locale => 'en_US'
      }
      send_frame(Qrack::Protocol09::Connection::StartOk.new(start_opts))

      frame = next_frame
      raise Bunny::ProtocolError, "Connection failed - user: #{@user}" if frame.nil?

      method = frame.payload

      if method.is_a?(Qrack::Protocol09::Connection::Tune)
        send_frame(Qrack::Protocol09::Connection::TuneOk.new(:channel_max => @channel_max, :frame_max => @frame_max, :heartbeat => @heartbeat))
      end

      send_frame(Qrack::Protocol09::Connection::Open.new(:virtual_host => @vhost, :reserved_1 => 0, :reserved_2 => false))

      raise Bunny::ProtocolError, 'Cannot open connection' unless next_method.is_a?(Qrack::Protocol09::Connection::OpenOk)
    end

    # Requests a specific quality of service. The QoS can be specified for the current channel
    # or for all channels on the connection. The particular properties and semantics of a QoS
    # method always depend on the content class semantics. Though the QoS method could in principle
    # apply to both peers, it is currently meaningful only for the server.
    #
    # @option opts [Integer] :prefetch_size (0)
    #   Size in number of octets. The client can request that messages be sent in advance
    #   so that when the client finishes processing a message, the following message is
    #   already held locally, rather than needing to be sent down the channel. refetching
    #   gives a performance improvement. This field specifies the prefetch window size
    #   in octets. The server will send a message in advance if it is equal to or smaller
    #   in size than the available prefetch size (and also falls into other prefetch limits).
    #   May be set to zero, meaning "no specific limit", although other prefetch limits may
    #   still apply. The prefetch-size is ignored if the no-ack option is set.
    #
    # @option opts [Integer] :prefetch_count (1)
    #   Number of messages to prefetch. Specifies a prefetch window in terms of whole messages.
    #   This field may be used in combination with the prefetch-size field; a message will only
    #   be sent in advance if both prefetch windows (and those at the channel and connection level)
    #   allow it. The prefetch-count is ignored if the no-ack option is set.
    #
    # @option opts [Boolean] :global (false)
    #   By default the QoS settings apply to the current channel only. If set to true,
    #   they are applied to the entire connection.
    #
    # @return [Symbol] @:qos_ok@ if successful.
    def qos(opts = {})
      send_frame(Qrack::Protocol09::Basic::Qos.new({ :prefetch_size => 0, :prefetch_count => 1, :global => false }.merge(opts)))

      method = next_method

      check_response(method, Qrack::Protocol09::Basic::QosOk, "Error specifying Quality of Service")

      # return confirmation
      :qos_ok
    end

    # Declares a queue to the broker/server. If the queue does not exist, a new one is created
    # using the arguments passed in. If the queue already exists, a reference to it is created, provided
    # that the arguments passed in do not conflict with the existing attributes of the queue. If an error
    # occurs a {Bunny::ProtocolError} is raised.
    #
    # @option opts [Boolean] :passive (false)
    #   If set to @true@, the server will not create the queue. The client can use this to check
    #   whether a queue exists without modifying the server state.
    #
    # @option opts [Boolean] :durable (false)
    #   If set to @true@ when creating a new queue, the queue will be marked as durable.
    #   Durable queues remain active when a server restarts. Non-durable queues (transient ones)
    #   are purged if/when a server restarts. Note that durable queues do not necessarily hold
    #   persistent messages, although it does not make sense to send persistent messages
    #   to a transient queue.
    #
    # @option opts [Boolean] :exclusive (false)
    #   If set to @true@, requests an exclusive queue. Exclusive queues may only be consumed
    #   from by the current connection. Setting the 'exclusive' flag always implies 'auto-delete'.
    #
    # @option opts [Boolean] :auto_delete (false)
    #   If set to @true@, the queue is deleted when all consumers have finished using it.
    #   Last consumer can be cancelled either explicitly or because its channel is closed.
    #   If there has never been a consumer on the queue, it is not deleted.
    #
    # @option opts [Boolean] :nowait (false)
    #   Ignored by Bunny, always @false@.
    #
    # @return [Bunny::Queue09]
    def queue(name = nil, opts = {})
      if name.is_a?(Hash)
        opts = name
        name = nil
      end

      # Queue is responsible for placing itself in the list of queues
      queues[name] || Bunny::Queue09.new(self, name, opts)
    end

    # Asks the broker to redeliver all unacknowledged messages on a specified channel. Zero or
    # more messages may be redelivered.
    #
    # @option opts [Boolean] :requeue (false)
    #   If set to @false@, the message will be redelivered to the original recipient.
    #   If set to @true@, the server will attempt to requeue the message, potentially
    #   then delivering it to an alternative subscriber.
    def recover(opts = {})
      send_frame(Qrack::Protocol09::Basic::Recover.new({ :requeue => false }.merge(opts)))
    end

    def send_frame(*args)
      args.each do |data|
        data         = data.to_frame(channel.number) unless data.is_a?(Qrack::Transport09::Frame)
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
      hb = Qrack::Transport09::Heartbeat.new('')
      # Channel 0 must be used
      switch_channel(0) if @channel.number > 0
      # Send the heartbeat to server
      send_frame(hb)
    end

    # Opens a communication channel and starts a connection. If an error occurs, a
    # {Bunny::ProtocolError} is raised. If successful, {Client.status} is set to @:connected@.
    #
    # @return [Symbol] @:connected@ if successful.
    def start_session
      @connecting = true

      # Create/get socket
      socket

      # Initiate connection
      init_connection

      # Open connection
      open_connection

      # Open another channel because channel zero is used for specific purposes
      c = create_channel()
      c.open

      @connecting = false

      # return status
      @status = :connected
    end

    alias start start_session

    # This method commits all messages published and acknowledged in
    # the current transaction. A new transaction starts immediately
    # after a commit.
    #
    # @return [Symbol] @:commit_ok@ if successful.
    def tx_commit
      send_frame(Qrack::Protocol09::Tx::Commit.new())

      method = next_method

      check_response(method, Qrack::Protocol09::Tx::CommitOk, "Error commiting transaction")

      # return confirmation
      :commit_ok
    end

    # This method abandons all messages published and acknowledged in
    # the current transaction. A new transaction starts immediately
    # after a rollback.
    #
    # @return [Symbol] @:rollback_ok@ if successful.
    def tx_rollback
      send_frame(Qrack::Protocol09::Tx::Rollback.new())

      method = next_method

      check_response(method, Qrack::Protocol09::Tx::RollbackOk, "Error rolling back transaction")

      # return confirmation
      :rollback_ok
    end

    # This method sets the channel to use standard transactions. The
    # client must use this method at least once on a channel before
    # using the Commit or Rollback methods.
    #
    # @return [Symbol] @:select_ok@ if successful.
    def tx_select
      send_frame(Qrack::Protocol09::Tx::Select.new())

      method = next_method

      check_response(method, Qrack::Protocol::Tx::SelectOk, "Error initiating transactions for current channel")

      # return confirmation
      :select_ok
    end

    private

    def buffer
      @buffer ||= Qrack::Transport09::Buffer.new(self)
    end

  end
end
