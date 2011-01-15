#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.


module Jobs
  class InviteUser
    extend ResqueJobLogging
    @queue = :mail
    def self.perform(sender_id, email, aspect_id, invite_message)
      user = User.find(sender_id)
      user.invite_user(email, aspect_id, invite_message)
    end
  end
end
