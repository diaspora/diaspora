#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Mention < ActiveRecord::Base
  belongs_to :post
  belongs_to :person
  validates :post, :presence => true
  validates :person, :presence => true

  after_destroy :delete_notification

  def notify_recipient
    logger.info "event=mention_sent id=#{id} to=#{person.diaspora_handle} from=#{post.author.diaspora_handle}"
    Notification.notify(person.owner, self, post.author) unless person.remote?
  end

  def notification_type(*args)
    Notifications::Mentioned
  end

  def delete_notification
    Notification.where(:target_type => self.class.name, :target_id => self.id).destroy_all
  end
end
