# encoding: utf-8

module Bunny

  # Queues store and forward messages. Queues can be configured in the server or created at runtime.
  # Queues must be attached to at least one exchange in order to receive messages from publishers.
  class Queue09 < Qrack::Queue
    def initialize(client, name, opts = {})
      # check connection to server
      raise Bunny::ConnectionError, 'Not connected to server' if client.status == :not_connected

      @client = client
      @opts   = opts
      @delivery_tag = nil

      # Queues without a given name are named by the server and are generally
      # bound to the process that created them.
      if !name
        opts = {
          :passive => false,
          :durable => false,
          :exclusive => true,
          :auto_delete => true,
          :deprecated_ticket => 0
        }.merge(opts)
      end

      # ignore the :nowait option if passed, otherwise program will hang waiting for a
      # response that will not be sent by the server
      opts.delete(:nowait)

      opts = { :queue => name || '', :nowait => false, :deprecated_ticket => 0 }.merge(opts)

      client.send_frame(Qrack::Protocol09::Queue::Declare.new(opts))

      method = client.next_method

      client.check_response(method, Qrack::Protocol09::Queue::DeclareOk, "Error declaring queue #{name}")

      @name = method.queue
      client.queues[@name] = self
    end

    # @return [Bunny::Consumer] Default consumer associated with this queue (if any), or nil
    # @note Default consumer is the one registered with the convenience {Bunny::Queue#subscribe} method. It has no special properties of any kind.
    # @see Queue#subscribe
    # @see Bunny::Consumer
    # @api public
    def default_consumer
      @default_consumer
    end

    # @return [Class]
    # @private
    def self.consumer_class
      # Bunny::Consumer
      Bunny::Subscription09
    end # self.consumer_class

    # Acknowledges one or more messages delivered via the _Deliver_ or _Get_-_Ok_ methods. The client can
    # ask to confirm a single message or a set of messages up to and including a specific message.
    #
    # @option opts [String] :delivery_tag
    #
    # @option opts [Boolean] :multiple (false)
    #   If set to @true@, the delivery tag is treated as "up to and including",
    #   so that the client can acknowledge multiple messages with a single method.
    #   If set to @false@, the delivery tag refers to a single message.
    #   If the multiple field is @true@, and the delivery tag is zero,
    #   tells the server to acknowledge all outstanding messages.
    def ack(opts = {})
      # Set delivery tag
      if delivery_tag.nil? and opts[:delivery_tag].nil?
        raise Bunny::AcknowledgementError, "No delivery tag received"
      else
        self.delivery_tag = opts[:delivery_tag] if delivery_tag.nil?
      end

      opts = {:delivery_tag => delivery_tag, :multiple => false}.merge(opts)

      client.send_frame(Qrack::Protocol09::Basic::Ack.new(opts))

      # reset delivery tag
      self.delivery_tag = nil
    end

    # Binds a queue to an exchange. Until a queue is bound it won't receive
    # any messages. Queues are bound to the direct exchange '' by default.
    # If error occurs, a {Bunny::ProtocolError} is raised.
    #
    # @option opts [String] :key
    #   Specifies the routing key for the binding. The routing key is used
    #   for routing messages depending on the exchange configuration.
    #
    # @option opts [Boolean] :nowait (false)
    #   Ignored by Bunny, always @false@.
    #
    # @return [Symbol] @:bind_ok@ if successful.
    def bind(exchange, opts = {})
      exchange = exchange.respond_to?(:name) ? exchange.name : exchange

      # ignore the :nowait option if passed, otherwise program will hang waiting for a
      # response that will not be sent by the server
      opts.delete(:nowait)

      opts = {
        :queue => name,
        :exchange => exchange,
        :routing_key => opts.delete(:key),
        :nowait => false,
        :deprecated_ticket => 0
      }.merge(opts)

      client.send_frame(Qrack::Protocol09::Queue::Bind.new(opts))

      method = client.next_method

      client.check_response(method, Qrack::Protocol09::Queue::BindOk, "Error binding queue: #{name} to exchange: #{exchange}")

      # return message
      :bind_ok
    end

    # Requests that a queue is deleted from broker/server. When a queue is deleted any pending messages
    # are sent to a dead-letter queue if this is defined in the server configuration. Removes reference
    # from queues if successful. If an error occurs raises @Bunny::ProtocolError@.
    #
    # @option opts [Boolean] :if_unused (false)
    #   If set to @true@, the server will only delete the queue if it has no consumers.
    #   If the queue has consumers the server does not delete it but raises a channel exception instead.
    #
    # @option opts [Boolean] :if_empty (false)
    #   If set to @true@, the server will only delete the queue if it has no messages.
    #   If the queue is not empty the server raises a channel exception.
    #
    # @option opts [Boolean] :nowait (false)
    #   Ignored by Bunny, always @false@.
    #
    # @return [Symbol] @:delete_ok@ if successful
    def delete(opts = {})
      # ignore the :nowait option if passed, otherwise program will hang waiting for a
      # response that will not be sent by the server
      opts.delete(:nowait)

      opts = { :queue => name, :nowait => false, :deprecated_ticket => 0 }.merge(opts)

      client.send_frame(Qrack::Protocol09::Queue::Delete.new(opts))

      method = client.next_method

      client.check_response(method, Qrack::Protocol09::Queue::DeleteOk, "Error deleting queue #{name}")

      client.queues.delete(name)

      # return confirmation
      :delete_ok
    end

    # Gets a message from a queue in a synchronous way. If error occurs, raises _Bunny_::_ProtocolError_.
    #
    # @option opts [Boolean] :ack (false)
    #   If set to @false@, the server does not expect an acknowledgement message
    #   from the client. If set to @true@, the server expects an acknowledgement
    #   message from the client and will re-queue the message if it does not receive
    #   one within a time specified by the server.
    #
    # @return [Hash] Hash with @:header@, @:payload@ and @:delivery_details@ keys. @:delivery_details@ is a hash @:consumer_tag@, @:delivery_tag@, @:redelivered@, @:exchange@ and @:routing_key@. If the queue is empty the returned hash will contain: @{:header => nil, :payload => :queue_empty, :delivery_details => nil}@. N.B. If a block is provided then the hash will be passed into the block and the return value will be nil.
    def pop(opts = {}, &blk)
      opts = {
        :queue => name,
        :consumer_tag => name,
        :no_ack => !opts[:ack],
        :nowait => true,
        :deprecated_ticket => 0
      }.merge(opts)

      client.send_frame(Qrack::Protocol09::Basic::Get.new(opts))

      method = client.next_method

      if method.is_a?(Qrack::Protocol09::Basic::GetEmpty) then
        queue_empty = true
      elsif !method.is_a?(Qrack::Protocol09::Basic::GetOk)
        raise Bunny::ProtocolError, "Error getting message from queue #{name}"
      end

      if !queue_empty
        # get delivery tag to use for acknowledge
        self.delivery_tag = method.delivery_tag if opts[:ack]

        header = client.next_payload

        # If maximum frame size is smaller than message payload body then message
        # will have a message header and several message bodies
        msg = ''
        while msg.length < header.size
          msg << client.next_payload
        end

        msg_hash = {:header => header, :payload => msg, :delivery_details => method.arguments}

      else
        msg_hash = {:header => nil, :payload => :queue_empty, :delivery_details => nil}
      end

      # Pass message hash to block or return message hash
      blk ? blk.call(msg_hash) : msg_hash
    end

    # Removes all messages from a queue.  It does not cancel consumers.  Purged messages are deleted
    # without any formal "undo" mechanism. If an error occurs raises {Bunny::ProtocolError}.
    #
    # @option opts [Boolean] :nowait (false)
    #   Ignored by Bunny, always @false@.
    #
    # @return [Symbol] @:purge_ok@ if successful
    def purge(opts = {})
      # ignore the :nowait option if passed, otherwise program will hang waiting for a
      # response that will not be sent by the server
      opts.delete(:nowait)

      opts = { :queue => name, :nowait => false, :deprecated_ticket => 0 }.merge(opts)

      client.send_frame(Qrack::Protocol09::Queue::Purge.new(opts))

      method = client.next_method

      client.check_response(method,   Qrack::Protocol09::Queue::PurgeOk, "Error purging queue #{name}")

      # return confirmation
      :purge_ok
    end

    # @return [Hash] Hash with keys @:message_count@ and @consumer_count@.
    def status
      opts = { :queue => name, :passive => true, :deprecated_ticket => 0 }
      client.send_frame(Qrack::Protocol09::Queue::Declare.new(opts))

      method = client.next_method
      {:message_count => method.message_count, :consumer_count => method.consumer_count}
    end

    def subscribe(opts = {}, &blk)
      raise RuntimeError.new("This queue already has default consumer. Please instantiate Bunny::Consumer directly and call its #consume method to register additional consumers.") if @default_consumer && ! opts[:consumer_tag]

      # Create a subscription.
      @default_consumer = self.class.consumer_class.new(client, self, opts)
      @default_consumer.consume(&blk)
    end

    # Removes a queue binding from an exchange. If error occurs, a _Bunny_::_ProtocolError_ is raised.
    #
    # @option opts [String] :key
    #   Specifies the routing key for the binding.
    #
    # @option opts [Boolean] :nowait (false)
    #   Ignored by Bunny, always @false@.
    #
    # @return [Symbol] @:unbind_ok@ if successful.
    def unbind(exchange, opts = {})
      exchange = exchange.respond_to?(:name) ? exchange.name : exchange

      # ignore the :nowait option if passed, otherwise program will hang waiting for a
      # response that will not be sent by the server
      opts.delete(:nowait)

      opts = {
        :queue => name,
        :exchange => exchange,
        :routing_key => opts.delete(:key),
        :nowait => false,
        :deprecated_ticket => 0
      }.merge(opts)

      client.send_frame(Qrack::Protocol09::Queue::Unbind.new(opts))

      method = client.next_method

      client.check_response(method, Qrack::Protocol09::Queue::UnbindOk, "Error unbinding queue #{name}")

      # return message
      :unbind_ok
    end

    # Cancels a consumer. This does not affect already delivered messages, but it does mean
    # the server will not send any more messages for that consumer.
    #
    # @option opts [String] :consumer_tag
    #   Specifies the identifier for the consumer.
    #
    # @option opts [Boolean] :nowait (false)
    #   Ignored by Bunny, always @false@.
    #
    # @return [Symbol] @:unsubscribe_ok@ if successful
    def unsubscribe(opts = {})
      # Default consumer_tag from subscription if not passed in
      consumer_tag = @default_consumer ? @default_consumer.consumer_tag : opts[:consumer_tag]

      # Must have consumer tag to tell server what to unsubscribe
      raise Bunny::UnsubscribeError,
      "No consumer tag received" if !consumer_tag

      # Cancel consumer
      client.send_frame(Qrack::Protocol09::Basic::Cancel.new(:consumer_tag => consumer_tag, :nowait => false))

      method = client.next_method

      client.check_response(method, Qrack::Protocol09::Basic::CancelOk, "Error unsubscribing from queue #{name}")

      # Reset subscription
      @default_consumer = nil

      # Return confirmation
      :unsubscribe_ok
    end

    private

    def exchange
      @exchange ||= Bunny::Exchange09.new(client, '', :type => :direct, :key => name, :reserved_1 => 0, :reserved_2 => false, :reserved_3 => false)
    end

  end

end
