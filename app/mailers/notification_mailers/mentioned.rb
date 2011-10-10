#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module NotificationMailers
  class Mentioned < NotificationMailers::Base
    attr_accessor :post

    def set_headers(target_id)
      @post = Mention.find_by_id(target_id).post

      @headers[:subject] = I18n.t('notifier.mentioned.subject', :name => @sender.name)
    end
  end
end