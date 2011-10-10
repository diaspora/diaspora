#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module NotificationMailers
  class Reshared < NotificationMailers::Base
    attr_accessor :reshare

    def set_headers(reshare_id)
      @reshare = Reshare.find(reshare_id)

      @headers[:subject] = I18n.t('notifier.reshared.reshared', :name => @sender.name)
    end
  end
end