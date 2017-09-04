# frozen_string_literal: true

module Diaspora
  module Federated
    class Generator
      include Diaspora::Logging

      def initialize(user, target)
        @user = user
        @target = target
      end

      def create!(options={})
        relayable = build(options)
        if relayable.save!
          logger.info "user:#{@user.id} dispatching #{relayable.class}:#{relayable.guid}"
          Diaspora::Federation::Dispatcher.defer_dispatch(@user, relayable)
          relayable
        end
      end

      def build(options={})
        self.class.federated_class.new(options.merge(relayable_options).merge(author_id: @user.person.id))
      end

      protected

      def relayable_options
        raise NotImplementedError, "You must override relayable_options"
      end
    end
  end
end
