#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.


module Job
  class MailRequestReceived < Base
    @queue = :mail
    def self.perform_delegate(recipient_id, sender_id, target_id)
      Notifier.new_request(recipient_id, sender_id).deliver
    end
  end
end

