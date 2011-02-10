#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Mention < ActiveRecord::Base
  belongs_to :post
  belongs_to :person
  validates_presence_of :post
  validates_presence_of :person

  after_create :notify_recipient

  def notify_recipient
    Notification.notify(person.owner, self, post.person) unless person.remote?
  end


  def notification_type
    'mentioned'
  end
end
