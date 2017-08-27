# frozen_string_literal: true

#   Copyright (c) 2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

namespace :maintenance do
  desc "Queue users for removal"
  task :queue_users_for_removal => :environment do
    # Queue users for removal due to inactivity
    # Note! settings.maintenance.remove_old_users
    # must still be enabled, this only bypasses
    # scheduling to run the queuing immediately
    Workers::QueueUsersForRemoval.perform_async
  end
end
