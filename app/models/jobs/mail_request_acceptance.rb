#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.


module Jobs
  class MailRequestAcceptance
    extend ResqueJobLogging
    @queue = :mail
    def self.perform(recipient_id, sender_id)
      Notifier.request_accepted(recipient_id, sender_id).deliver
    end
  end
end

