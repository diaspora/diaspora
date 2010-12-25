#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.
#
class Notification
  require File.join(Rails.root, 'lib/diaspora/web_socket')
  include MongoMapper::Document
  include Diaspora::Socketable

  key :target_id, ObjectId
  key :kind, String
  key :unread, Boolean, :default => true

  belongs_to :user
  belongs_to :person

  timestamps!

  attr_accessible :target_id, :kind, :user_id, :person_id, :unread

  def self.for(user, opts={})
    self.where(opts.merge!(:user_id => user.id)).order('created_at desc')
  end

  def self.notify(user, object, person)
    if object.respond_to? :notification_type
      if kind = object.notification_type(user, person)
        n = Notification.create(:target_id => object.id,
                            :kind => kind,
                            :person_id => person.id,
                            :user_id => user.id)
        n.socket_to_uid(user.id) if n
        n
       end
    end
  end
end
