# encoding: utf-8

module Bunny

  # *Exchanges* are the routing and distribution hub of AMQP. All messages that Bunny sends
  # to an AMQP broker/server @have_to pass through an exchange in order to be routed to a
  # destination queue. The AMQP specification defines the types of exchange that you can create.
  #
  # At the time of writing there are four (4) types of exchange defined:
  #
  # * @:direct@
  # * @:fanout@
  # * @:topic@
  # * @:headers@
  #
  # AMQP-compliant brokers/servers are required to provide default exchanges for the @direct@ and
  # @fanout@ exchange types. All default exchanges are prefixed with @'amq.'@, for example:
  #
  # * @amq.direct@
  # * @amq.fanout@
  # * @amq.topic@
  # * @amq.match@ or @amq.headers@
  #
  # If you want more information about exchanges, please consult the documentation for your
  # target broker/server or visit the "AMQP website":http://www.amqp.org to find the version of the
  # specification that applies to your target broker/server.
  class Exchange09

    attr_reader :client, :type, :name, :opts, :key

    def initialize(client, name, opts = {})
      # check connection to server
      raise Bunny::ConnectionError, 'Not connected to server' if client.status == :not_connected

      @client, @name, @opts = client, name, opts

      # set up the exchange type catering for default names
      if name =~ /^amq\.(.+)$/
        predeclared = true
        new_type = $1
        # handle 'amq.match' default
        new_type = 'headers' if new_type == 'match'
        @type = new_type.to_sym
      else
        @type = opts[:type] || :direct
      end

      @key = opts[:key]
      @client.exchanges[@name] ||= self

      # ignore the :nowait option if passed, otherwise program will hang waiting for a
      # response that will not be sent by the server
      opts.delete(:nowait)

      unless predeclared or name == ''
        opts = {
          :exchange => name, :type => type, :nowait => false,
          :deprecated_ticket => 0, :deprecated_auto_delete => false, :deprecated_internal => false
        }.merge(opts)

        client.send_frame(Qrack::Protocol09::Exchange::Declare.new(opts))

        method = client.next_method

        client.check_response(method, Qrack::Protocol09::Exchange::DeclareOk, "Error declaring exchange #{name}: type = #{type}")
      end
    end

    # Requests that an exchange is deleted from broker/server. Removes reference from exchanges
    # if successful. If an error occurs raises {Bunny::ProtocolError}.
    #
    # @option opts [Boolean] :if_unused (false)
    #   If set to @true@, the server will only delete the exchange if it has no queue bindings. If the exchange has queue bindings the server does not delete it but raises a channel exception instead.
    #
    # @option opts [Boolean] :nowait (false)
    #   Ignored by Bunny, always @false@.
    #
    # @return [Symbol] @:delete_ok@ if successful.
    def delete(opts = {})
      # ignore the :nowait option if passed, otherwise program will hang waiting for a
      # response that will not be sent by the server
      opts.delete(:nowait)

      opts = { :exchange => name, :nowait => false, :deprecated_ticket => 0 }.merge(opts)

      client.send_frame(Qrack::Protocol09::Exchange::Delete.new(opts))

      method = client.next_method

      client.check_response(method, Qrack::Protocol09::Exchange::DeleteOk, "Error deleting exchange #{name}")

      client.exchanges.delete(name)

      # return confirmation
      :delete_ok
    end

    # Publishes a message to a specific exchange. The message will be routed to queues as defined
    # by the exchange configuration and distributed to any active consumers when the transaction,
    # if any, is committed.
    #
    # @option opts [String] :key
    #   Specifies the routing key for the message. The routing key is
    #   used for routing messages depending on the exchange configuration.
    #
    # @option opts [String] :content_type
    #   Specifies the content type for the message.
    #
    # @option opts [Boolean] :mandatory (false)
    #   Tells the server how to react if the message cannot be routed to a queue.
    #   If set to @true@, the server will return an unroutable message
    #   with a Return method. If this flag is zero, the server silently drops the message.
    #
    # @option opts [Boolean] :immediate (false)
    #   Tells the server how to react if the message cannot be routed to a queue consumer
    #   immediately. If set to @true@, the server will return an undeliverable message with
    #   a Return method. If set to @false@, the server will queue the message, but with no
    #   guarantee that it will ever be consumed.
    #
    # @option opts [Boolean] :persistent (false)
    #   Tells the server whether to persist the message. If set to @true@, the message will
    #   be persisted to disk and not lost if the server restarts. If set to @false@, the message
    #   will not be persisted across server restart. Setting to @true@ incurs a performance penalty
    #   as there is an extra cost associated with disk access.
    #
    # @return [NilClass] nil
    def publish(data, opts = {})
      opts = opts.dup
      out = []

      # Set up options
      routing_key = opts.delete(:key) || key
      mandatory = opts.delete(:mandatory)
      immediate = opts.delete(:immediate)
      delivery_mode = opts.delete(:persistent) ? 2 : 1
      content_type = opts.delete(:content_type) || 'application/octet-stream'

      out << Qrack::Protocol09::Basic::Publish.new({ :exchange => name,
                                                     :routing_key => routing_key,
                                                     :mandatory => mandatory,
                                                     :immediate => immediate,
                                                     :deprecated_ticket => 0 })
      data = data.to_s
      out << Qrack::Protocol09::Header.new(
                                           Qrack::Protocol09::Basic,
                                           data.bytesize, {
                                             :content_type  => content_type,
                                             :delivery_mode => delivery_mode,
                                             :priority      => 0
                                           }.merge(opts)
                                           )
      out << Qrack::Transport09::Body.new(data)

      client.send_frame(*out)
    end

  end

end
