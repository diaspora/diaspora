#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Mention < ActiveRecord::Base
  belongs_to :post
  belongs_to :person
  validates_presence_of :post
  validates_presence_of :person

  after_destroy :delete_notification

  def notify_recipient
    Rails.logger.info "event=mention_sent id=#{self.id} to=#{person.diaspora_handle} from=#{post.person.diaspora_handle}"
    Notification.notify(person.owner, self, post.person) unless person.remote?
  end


  def notification_type(*args)
    Notifications::Mentioned
  end

  def delete_notification
    Notification.where(:target_type => self.class.name, :target_id => self.id).delete_all
  end
end
