# encoding: utf-8

module Qrack

  # Queue ancestor class
  class Queue

    # @return [AMQ::Client::Consumer] Default consumer (registered with {Queue#subscribe}).
    attr_accessor :default_consumer

    attr_reader :name, :client

    attr_accessor :delivery_tag


    # Returns consumer count from {Queue#status}.
    def consumer_count
      s = status
      s[:consumer_count]
    end

    # Returns message count from {Queue#status}.
    def message_count
      s = status
      s[:message_count]
    end

    # Publishes a message to the queue via the default nameless '' direct exchange.

    # @return [NilClass] nil
    # @deprecated
    # @note This method will be removed before 0.8 release.
    def publish(data, opts = {})
      Bunny.deprecation_warning("Qrack::Queue#publish", "0.8", "Use direct_exchange = bunny.exchange(''); direct_exchange.publish('message', key: queue.name) if you want to publish directly to one given queue. For more informations see https://github.com/ruby-amqp/bunny/issues/15 and for more theoretical explanation check http://bit.ly/nOF1CK")
      exchange.publish(data, opts)
    end

  end

end
