#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.


module Jobs
  module Mail
    class Mentioned < Base
      @queue = :mail
      def self.perform(recipient_id, actor_id, target_id)
        Notifier.mentioned( recipient_id, actor_id, target_id).deliver
      end
    end
  end
end
