#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Workers
  class ReceiveLocalBatch < Base
    sidekiq_options queue: :receive

    def perform(object_class_string, object_id, recipient_user_ids)
      object = object_class_string.constantize.find(object_id)
      receiver = Postzord::Receiver::LocalBatch.new(object, recipient_user_ids)
      receiver.perform!
    end
  end
end
