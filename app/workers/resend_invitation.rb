#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.


module Workers
  class ResendInvitation < Base
    sidekiq_options queue: :mail
    
    def perform(invitation_id)
      inv = Invitation.find(invitation_id)
      inv.resend
    end
  end
end
