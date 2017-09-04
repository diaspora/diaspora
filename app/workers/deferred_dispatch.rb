# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Workers
  class DeferredDispatch < Base
    sidekiq_options queue: :high

    def perform(user_id, object_class_name, object_id, opts)
      user = User.find(user_id)
      object = object_class_name.constantize.find(object_id)
      opts = ActiveSupport::HashWithIndifferentAccess.new(opts)

      Diaspora::Federation::Dispatcher.build(user, object, opts).dispatch
    rescue ActiveRecord::RecordNotFound # The target got deleted before the job was run
    end
  end
end
