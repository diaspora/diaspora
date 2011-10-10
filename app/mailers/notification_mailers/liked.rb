#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module NotificationMailers
  class Liked < NotificationMailers::Base
    attr_accessor :like

    def set_headers(like_id)
      @like = Like.find(like_id)

      @headers[:subject] = I18n.t('notifier.liked.liked', :name => @sender.name)
    end
  end
end