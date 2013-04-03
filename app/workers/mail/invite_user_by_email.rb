#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Workers
  module Mail
    class InviteUserByEmail < Base
      sidekiq_options queue: :mail
      
      def perform(invite_id)
        invite = Invitation.find(invite_id)
        I18n.with_locale(invite.language) do
          invite.send!
        end
      end
    end
  end
end
