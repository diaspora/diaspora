#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.


module Job
  class ResendInvitation < Base
    @queue = :mail
    def self.perform_delegate(invitation_id)
      inv = Invitation.where(:id => invitation_id).first
      inv.resend
    end
  end
end
