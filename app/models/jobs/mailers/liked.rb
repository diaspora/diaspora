#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Jobs
  module Mailers
    class Liked < Base
      @queue = :mail
      def self.perform(recipient_id, sender_id, like_id)
        Notifier.liked(recipient_id, sender_id, like_id).deliver
      end
    end
  end
end

