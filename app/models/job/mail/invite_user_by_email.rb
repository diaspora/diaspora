#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.


module Job
  module Mail
    class InviteUserByEmail < Base
      @queue = :mail
      def self.perform(invite_id)
        invite = Invitation.find(invite_id)
        invite.send!
      end
    end
  end
end
