#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module NotificationMailers
  class ConfirmEmail < NotificationMailers::Base
    def set_headers
      @headers[:to] = "#{@recipient.profile.first_name} <#{@recipient.unconfirmed_email}>"
      @headers[:subject] = I18n.t('notifier.confirm_email.subject', :unconfirmed_email => @recipient.unconfirmed_email)
    end
  end
end
