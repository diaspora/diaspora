# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Workers
  class DeferredRetraction < Base
    sidekiq_options queue: :high

    def perform(user_id, retraction_class, retraction_data, recipient_ids, opts)
      user = User.find(user_id)
      subscribers = Person.where(id: recipient_ids)
      object = retraction_class.constantize.new(retraction_data.deep_symbolize_keys, subscribers)
      opts = ActiveSupport::HashWithIndifferentAccess.new(opts)

      Diaspora::Federation::Dispatcher.build(user, object, opts).dispatch
    end
  end
end
