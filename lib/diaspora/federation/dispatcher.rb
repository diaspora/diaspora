# frozen_string_literal: true

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
        sender = object.try(:sender_for_dispatch) || sender
        if object.try(:public?)
          Public.new(sender, object, opts)
        else
          Private.new(sender, object, opts)
        end
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

      def entity
        @entity ||= Entities.build(object)
      end

      def magic_envelope
        @magic_envelope ||= DiasporaFederation::Salmon::MagicEnvelope.new(
          entity, sender.diaspora_handle
        ).envelop(sender.encryption_key)
      end

      def deliver_to_services
        deliver_to_user_services if opts[:service_types]
      end

      def deliver_to_subscribers
        local_people, remote_people = subscribers.uniq(&:id).partition(&:local?)

        deliver_to_local(local_people) unless local_people.empty?
        deliver_to_remote(remote_people)
      end

      def deliver_to_local(people)
        object_to_receive = object.object_to_receive
        return unless object_to_receive
        Workers::ReceiveLocal.perform_async(object_to_receive.class.to_s, object_to_receive.id, people.map(&:owner_id))
      end

      def deliver_to_remote(_people)
        raise NotImplementedError, "This is an abstract base method. Implement in your subclass."
      end

      def deliver_to_user_services
        case object
        when StatusMessage
          each_service {|service| Workers::PostToService.perform_async(service.id, object.id, opts[:url]) }
        when Retraction
          each_service {|service| Workers::DeletePostFromService.perform_async(service.id, opts) }
        end
      end

      def each_service
        sender.services.where(type: opts[:service_types]).each {|service| yield(service) }
      end

      def subscribers
        opts[:subscribers] || subscribers_from_ids || object.subscribers
      end

      def subscribers_from_ids
        Person.where(id: opts[:subscriber_ids]) if opts[:subscriber_ids]
      end
    end
  end
end

require "diaspora/federation/dispatcher/private"
require "diaspora/federation/dispatcher/public"
