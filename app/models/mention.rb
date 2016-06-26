#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Mention < ActiveRecord::Base
  belongs_to :post
  belongs_to :person
  validates :post, presence: true
  validates :person, presence: true

  after_destroy :delete_notification

  def delete_notification
    Notification.where(target_type: self.class.name, target_id: id).destroy_all
  end
end
