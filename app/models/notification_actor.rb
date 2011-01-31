#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class NotificationActor < ActiveRecord::Base

  belongs_to :notification
  belongs_to :person

end
