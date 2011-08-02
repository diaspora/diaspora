# encoding: utf-8

module Bunny

  # Asks the server to start a "consumer", which is a transient request for messages from a specific
  # queue. Consumers last as long as the channel they were created on, or until the client cancels them
  # with an @unsubscribe@. Every time a message reaches the queue it is passed to the @blk@ for
  # processing. If error occurs, {Bunny::ProtocolError} is raised.
  #
  # @option opts [String] :consumer_tag
  #   Specifies the identifier for the consumer. The consumer tag is
  #   local to a connection, so two clients can use the same consumer tags.
  #   If this option is not specified a server generated name is used.
  #
  # @option opts [Boolean] :ack (false)
  #   If set to @false@, the server does not expect an acknowledgement message
  #   from the client. If set to @true, the server expects an acknowledgement
  #   message from the client and will re-queue the message if it does not
  #   receive one within a time specified by the server.
  #
  # @option opts [Boolean] :exclusive (false)
  #   Request exclusive consumer access, meaning only this consumer can access the queue.
  #
  # @option opts [Boolean] :nowait (false)
  #   Ignored by Bunny, always @false@.
  #
  # @option opts [Numeric] :timeout
  #   The subscribe loop will continue to wait for messages
  #   until terminated (Ctrl-C or kill command) or this timeout interval is reached.
  #
  # @option opts [Integer] :message_max
  #   When the required number of messages is processed subscribe loop is exited.
  #
  # h2. Operation
  #
  # Passes a hash of message information to the block, if one has been supplied. The hash contains
  # :header, :payload and :delivery_details. The structure of the data is as follows -
  #
  # :header has instance variables -
  #   @klass
  #   @size
  #   @weight
  #   @properties is a hash containing -
  #     :content_type
  #     :delivery_mode
  #     :priority
  #
  # :payload contains the message contents
  #
  # :delivery details is a hash containing -
  #   :consumer_tag
  #   :delivery_tag
  #   :redelivered
  #   :exchange
  #   :routing_key
  #
  # If the :timeout option is specified then the subscription will
  # automatically cease if the given number of seconds passes with no
  # message arriving.
  #
  # @example
  #   my_queue.subscribe(timeout: 5) { |msg| puts msg[:payload] }
  #   my_queue.subscribe(message_max: 10, ack: true) { |msg| puts msg[:payload] }
  class Subscription09 < Bunny::Consumer

    def setup_consumer
      subscription_options = {
        :deprecated_ticket => 0,
        :queue => queue.name,
        :consumer_tag => consumer_tag,
        :no_ack => !ack,
        :exclusive => exclusive,
        :nowait => false
      }.merge(@opts)

      client.send_frame(Qrack::Protocol09::Basic::Consume.new(subscription_options))

      method = client.next_method

      client.check_response(method, Qrack::Protocol09::Basic::ConsumeOk, "Error subscribing to queue #{queue.name}")

      @consumer_tag = method.consumer_tag
    end

  end

end
