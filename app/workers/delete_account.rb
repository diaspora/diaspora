# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.


module Workers
  class DeleteAccount < Base
    sidekiq_options queue: :low
    
    def perform(account_deletion_id)
      account_deletion = AccountDeletion.find(account_deletion_id)
      account_deletion.perform!
    end
  end
end
