#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Jobs
  module Mailers
    class AlsoCommented < Base
      @queue = :mail
      def self.perform(recipient_id, sender_id, comment_id)
        if email = Notifier.also_commented(recipient_id, sender_id, comment_id)
          email.deliver
        end
      end
    end
  end
end

