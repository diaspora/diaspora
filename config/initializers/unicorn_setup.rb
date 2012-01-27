#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.
if defined? Unicorn
  Rails.application.middleware.insert(0, UnicornKiller::Oom, 400 * 1024) #kill a unicorn that has gone over 400mB
  NewRelic::Agent.after_fork(:force_reconnect => true) if defined?(NewRelic)
end