#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Workers
  class QueueUsersForRemoval < Base
    include Sidetiq::Schedulable
    
    sidekiq_options queue: :maintenance
    
    recurrence { daily }
    
    def perform
      # Queue users for removal due to inactivity
      if AppConfig.settings.maintenance.remove_old_users.enable?
        users = User.where("last_seen < ? and locked_at is null and remove_after is null", 
          Time.now - (AppConfig.settings.maintenance.remove_old_users.after_days.to_i).days)
          .order(:last_seen)
          .limit(AppConfig.settings.maintenance.remove_old_users.limit_removals_to_per_day)

        # deliver to be closed emails to account holders
        # and queue accounts for closing to sidekiq
        # for those who have not signed in, skip warning and queue removal
        # in +1 days
        users.find_each do |user|
          if user.sign_in_count > 0
            remove_at = Time.now + AppConfig.settings.maintenance.remove_old_users.warn_days.to_i.days
          else
            remove_at = Time.now
          end
          user.flag_for_removal(remove_at)
          if user.sign_in_count > 0
            # send a warning
            Maintenance.account_removal_warning(user).deliver
          end
          Workers::RemoveOldUser.perform_in(remove_at+1.day, user.id)
        end
      end
    end
  end 
end