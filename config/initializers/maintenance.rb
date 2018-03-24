# frozen_string_literal: true

# Copyright (c) 2010-2011, Diaspora Inc.  This file is
# licensed under the Affero General Public License version 3 or later.  See
# the COPYRIGHT file.

unless AppConfig.mail.enable?
  if AppConfig.settings.maintenance.remove_old_users.enable?
    # The maintenance job remove_old_users will warn users
    # of inactivity removal before removing the users.
    # Warn podmins here that enable it but don't have mail enabled.
    puts "
WARNING: Maintenance that removes inactive users is enabled
but mail is disabled! This means there will be no warning email
sent to users whose accounts are flagged for removal!
See configuration setting 'settings.maintenance.remove_old_users'."
  end
end