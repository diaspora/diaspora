module Diaspora
  module Federation
    class Dispatcher
      include Diaspora::Logging

      def initialize(sender, object, opts={})
        @sender = sender
        @object = object
        @opts = opts
      end

      def self.build(sender, object, opts={})
        new(sender, object, opts)
      end

      def self.defer_dispatch(sender, object, opts={})
        Workers::DeferredDispatch.perform_async(sender.id, object.class.to_s, object.id, opts)
      end

      def dispatch
        deliver_to_services
        deliver_to_subscribers
      end

      private

      attr_reader :sender, :object, :opts

      def deliver_to_services
        # TODO: pubsubhubbub, relay, social-network-services
      end

      def deliver_to_subscribers
        local_people, remote_people = object.subscribers.partition(&:local?)

        deliver_to_local(local_people) unless local_people.empty?
        deliver_to_remote(remote_people) unless remote_people.empty?
      end

      def deliver_to_local(people)
        Workers::ReceiveLocal.perform_async(object.class.to_s, object.id, people.map(&:owner_id))
      end

      def deliver_to_remote(people)
        # TODO: send to remote hosts
      end
    end
  end
end
