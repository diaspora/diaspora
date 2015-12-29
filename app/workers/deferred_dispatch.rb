#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Workers
  class DeferredDispatch < Base
    sidekiq_options queue: :high

    def perform(user_id, object_class_name, object_id, opts)
      user = User.find(user_id)
      object = object_class_name.constantize.find(object_id)
      opts = HashWithIndifferentAccess.new(opts)
      opts[:services] = user.services.where(type: opts.delete(:service_types))

      add_additional_subscribers(object, object_class_name, opts)
      Postzord::Dispatcher.build(user, object, opts).post
    rescue ActiveRecord::RecordNotFound # The target got deleted before the job was run
    end

    def add_additional_subscribers(object, object_class_name, opts)
      if AppConfig.relay.outbound.send? &&
         object_class_name == "StatusMessage" &&
         object.respond_to?(:public?) && object.public?
        handle_relay(opts)
      end

      if opts[:additional_subscribers].present?
        opts[:additional_subscribers] = Person.where(id: opts[:additional_subscribers])
      end
    end

    def handle_relay(opts)
      relay_person = Person.find_by diaspora_handle: AppConfig.relay.outbound.handle.to_s
      if relay_person
        add_person_to_subscribers(opts, relay_person)
      else
        # Skip this message for relay and just queue a webfinger fetch for the relay handle
        Workers::FetchWebfinger.perform_async(AppConfig.relay.outbound.handle)
      end
    end

    def add_person_to_subscribers(opts, person)
      opts[:additional_subscribers] ||= []
      opts[:additional_subscribers] << person.id
    end
  end
end
