#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require File.join(Rails.root, 'lib/postzord/receiver/private')
require File.join(Rails.root, 'lib/postzord/receiver/local_batch')

module Jobs
  class ReceiveLocalBatch < Base

    @queue = :receive

    def self.perform(object_class_string, object_id, recipient_user_ids)


      object = object_class_string.constantize.find(object_id)

      #recipient user ids could be really bad
      receiver = Postzord::Receiver::LocalBatch.new(object, recipient_user_ids)
      receiver.perform!
    end
  end
end
