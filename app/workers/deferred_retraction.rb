#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Workers
  class DeferredRetraction < Base
    sidekiq_options queue: :high

    def perform(user_id, retraction_data, recipient_ids, opts)
      user = User.find(user_id)
      subscribers = Person.where(id: recipient_ids)
      object = Retraction.new(retraction_data.deep_symbolize_keys, subscribers)
      opts = HashWithIndifferentAccess.new(opts)

      Diaspora::Federation::Dispatcher.build(user, object, opts).dispatch
    end
  end
end
