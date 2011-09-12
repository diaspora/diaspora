#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require File.join(Rails.root, 'lib/postzord/receiver')
require File.join(Rails.root, 'lib/postzord/receiver/local_post_batch')

module Job
  class ReceiveLocalBatch < Base

    @queue = :receive

    def self.perform(post_id, recipient_user_ids)
      post = Post.find(post_id)
      receiver = Postzord::Receiver::LocalPostBatch.new(post, recipient_user_ids)
      receiver.perform!
    end
  end
end
