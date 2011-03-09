#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.


module Job
  class MailPrivateMessage < Base
    @queue = :mail
    def self.perform_delegate(recipient_id, actor_id, target_id)
      Notifier.private_message( recipient_id, actor_id, target_id).deliver
    end
  end
end
