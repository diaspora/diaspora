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
        # TODO: pubsubhubbub, relay
        deliver_to_user_services
      end

      def deliver_to_subscribers
        local_people, remote_people = object.subscribers.partition(&:local?)

        deliver_to_local(local_people) unless local_people.empty?
        deliver_to_remote(remote_people) unless remote_people.empty?
      end

      def deliver_to_local(people)
        obj = object.respond_to?(:object_to_receive) ? object.object_to_receive : object
        return unless obj
        Workers::ReceiveLocal.perform_async(obj.class.to_s, obj.id, people.map(&:owner_id))
      end

      def deliver_to_remote(people)
        # TODO: send to remote hosts
      end

      def deliver_to_user_services
        services.each do |service|
          case object
          when StatusMessage
            Workers::PostToService.perform_async(service.id, object.id, opts[:url])
          when Retraction
            Workers::DeletePostFromService.perform_async(service.id, object.target.id)
          end
        end
      end

      def services
        if opts[:services]
          opts[:services]
        elsif opts[:service_types]
          sender.services.where(type: opts[:service_types])
        else
          []
        end
      end
    end
  end
end
