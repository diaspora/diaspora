#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.


module Job
  class MailStartedSharing < Base
    @queue = :mail
    def self.perform(recipient_id, sender_id, target_id)
      Notifier.started_sharing(recipient_id, sender_id).deliver
    end
  end
end

