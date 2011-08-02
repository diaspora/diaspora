# encoding: utf-8

require "qrack/amq-client-url"

module Qrack

  class ClientTimeout < Timeout::Error; end
  class ConnectionTimeout < Timeout::Error; end
  class FrameTimeout < Timeout::Error; end

  # Client ancestor class
  class Client

    CONNECT_TIMEOUT = 5.0
    RETRY_DELAY     = 10.0

    attr_reader   :status, :host, :vhost, :port, :logging, :spec, :heartbeat
    attr_accessor :channel, :logfile, :exchanges, :queues, :channels, :message_in, :message_out, :connecting

    # Temporary hack to make Bunny 0.7 work with port number in AMQP URL.
    # This is not necessary on Bunny 0.8 as it removes support of AMQP 0.8.
    attr_reader :__opts__

    def initialize(connection_string_or_opts = Hash.new, opts = Hash.new)
      opts = case connection_string_or_opts
      when String then
        AMQ::Client::Settings.parse_amqp_url(connection_string_or_opts)
      when Hash then
        connection_string_or_opts
      else
        Hash.new
      end.merge(opts)

      # Temporary hack to make Bunny 0.7 work with port number in AMQP URL.
      # This is not necessary on Bunny 0.8 as it removes support of AMQP 0.8.
      @__opts__ = opts


      @host   = opts[:host] || 'localhost'
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
      @read_write_timeout = opts[:socket_timeout]
      @read_write_timeout = nil if @read_write_timeout == 0
      @disconnect_timeout = @read_write_timeout || @connect_timeout
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


    # Closes all active communication channels and connection. If an error occurs a @Bunny::ProtocolError@ is raised. If successful, @Client.status@ is set to @:not_connected@.

    # @return [Symbol] @:not_connected@ if successful.
    def close
      return if @socket.nil? || @socket.closed?

      # Close all active channels
      channels.each do |c|
        Bunny::Timer::timeout(@disconnect_timeout) { c.close } if c.open?
      end

      # Close connection to AMQP server
      Bunny::Timer::timeout(@disconnect_timeout) { close_connection }

    rescue Exception
      # http://cheezburger.com/Asset/View/4033311488
    ensure
      # Clear the channels
      @channels = []

      # Create channel 0
      @channel = create_channel()

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
      res = next_frame(options)
      res.payload if res
    end

    alias next_method next_payload

    def read(*args)
      send_command(:read, *args)
      # Got a SIGINT while waiting; give any traps a chance to run
    rescue Errno::EINTR
      retry
    end

  # Checks to see whether or not an undeliverable message has been returned as a result of a publish
  # with the <tt>:immediate</tt> or <tt>:mandatory</tt> options.

  # @param [Hash] opts Options.
  # @option opts [Numeric] :timeout (0.1) The method will wait for a return message until this timeout interval is reached.
  # @return [Hash] @{:header => nil, :payload => :no_return, :return_details => nil}@ if message is not returned before timeout. @{:header, :return_details, :payload}@ if message is returned. @:return_details@ is a hash @{:reply_code, :reply_text, :exchange, :routing_key}@.
    def returned_message(opts = {})

      begin
        frame = next_frame(:timeout => opts[:timeout] || 0.1)
      rescue Qrack::FrameTimeout
        return {:header => nil, :payload => :no_return, :return_details => nil}
      end

      method = frame.payload
      header = next_payload

      # If maximum frame size is smaller than message payload body then message
      # will have a message header and several message bodies
      msg = ''
      while msg.length < header.size
        msg << next_payload
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
        if @read_write_timeout
          Bunny::Timer::timeout(@read_write_timeout, Qrack::ClientTimeout) do
            @socket.__send__(cmd, *args)
          end
        else
          @socket.__send__(cmd, *args)
        end
      rescue Errno::EPIPE, Errno::EAGAIN, Qrack::ClientTimeout, IOError => e
        # Ensure we close the socket when we are down to prevent further
        # attempts to write to a closed socket
        close_socket
        raise Bunny::ServerDownError, e.message
      end
    end

    def socket
      return @socket if @socket and (@status == :connected) and not @socket.closed?

      begin
        # Attempt to connect.
        @socket = Bunny::Timer::timeout(@connect_timeout, ConnectionTimeout) do
          TCPSocket.new(host, port)
        end

        if Socket.constants.include?('TCP_NODELAY') || Socket.constants.include?(:TCP_NODELAY)
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
