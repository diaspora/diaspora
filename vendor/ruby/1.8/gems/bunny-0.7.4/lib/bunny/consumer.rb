# encoding: utf-8

####################################
# NOTE: THIS CLASS IS HERE TO MAKE #
# TRANSITION TO AMQ CLIENT EASIER  #
####################################

require "qrack/subscription"

# NOTE: This file is rather a temporary hack to fix
# https://github.com/ruby-amqp/bunny/issues/9 then
# some permanent solution. It's mostly copied from
# the AMQP and AMQ Client gems. Later on we should
# use AMQ Client directly and just inherit from
# the AMQ::Client::Sync::Consumer class.

module Bunny

  # AMQP consumers are entities that handle messages delivered
  # to them ("push API" as opposed to "pull API") by AMQP broker.
  # Every consumer is associated with a queue. Consumers can be
  # exclusive (no other consumers can be registered for the same
  # queue) or not (consumers share the queue). In the case of
  # multiple consumers per queue, messages are distributed in
  # round robin manner with respect to channel-level prefetch
  # setting).
  class Consumer < Qrack::Subscription
    def initialize(*args)
      super(*args)
      @consumer_tag ||= (1..32).to_a.shuffle.join
    end

    alias_method :consume, :start
  end
end
