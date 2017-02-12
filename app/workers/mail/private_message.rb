#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.


module Workers
  module Mail
    class PrivateMessage < Base
      sidekiq_options queue: :low
      
      def perform(recipient_id, actor_id, target_id)
        Notifier.private_message( recipient_id, actor_id, target_id).deliver_now
      end
    end
  end
end
