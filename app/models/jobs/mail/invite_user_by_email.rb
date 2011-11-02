#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.


module Jobs
  module Mail
    class InviteUserByEmail < Base
      @queue = :mail
      def self.perform(invite_id)
        invite = Invitation.find(invite_id)
        I18n.with_locale(invite.language) do
          invite.send!
        end
      end
    end
  end
end
