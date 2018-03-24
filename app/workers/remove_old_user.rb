# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Workers
  class RemoveOldUser < Base
    sidekiq_options queue: :low
    
    def safe_remove_after
      # extra safety time to compare in addition to remove_after
      Time.now-
        (AppConfig.settings.maintenance.remove_old_users.after_days.to_i).days-
        (AppConfig.settings.maintenance.remove_old_users.warn_days.to_i).days
    end
    
    def perform(user_id)
      # if user has been flagged as to be removed (see settings.maintenance.remove_old_users)
      # and hasn't logged in since that flag has been set, we remove the user
      if AppConfig.settings.maintenance.remove_old_users.enable?
        user = User.find(user_id)
        if user.remove_after < Time.now and user.last_seen < self.safe_remove_after
          user.close_account!
        end
      end
    end
  end 
end
