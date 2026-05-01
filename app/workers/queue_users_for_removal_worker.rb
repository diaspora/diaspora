# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class QueueUsersForRemovalWorker < BaseWorker
  sidekiq_options queue: :low

  def perform
    # Queue users for removal due to inactivity
    return unless AppConfig.settings.maintenance.remove_old_users.enable?

    users = User.where(
      "last_seen < ? and locked_at is null and remove_after is null",
      Time.current - AppConfig.settings.maintenance.remove_old_users.after_days.to_i.days
    )
                .order(:last_seen)
                .limit(AppConfig.settings.maintenance.remove_old_users.limit_removals_to_per_day)

    # deliver to be closed emails to account holders
    # and queue accounts for closing to sidekiq
    # for those who have not signed in, skip warning and queue removal
    # in +1 days
    users.each do |user|
      remove_at = if user.sign_in_count > 0
                    Time.current + AppConfig.settings.maintenance.remove_old_users.warn_days.to_i.days
                  else
                    Time.current
                  end

      user.flag_for_removal(remove_at)

      if user.sign_in_count > 0
        # send a warning
        Maintenance.account_removal_warning(user).deliver_now
      end

      RemoveOldUserWorker.perform_in(remove_at + 1.day, user.id)
    end
  end
end
