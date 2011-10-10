#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module NotificationMailers
  class StartedSharing < NotificationMailers::Base
    def set_headers
      @headers[:subject] = I18n.t('notifier.started_sharing.subject', :name => @sender.name)
    end
  end
end
