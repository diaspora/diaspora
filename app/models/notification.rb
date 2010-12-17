#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.
#
class Notification
  include MongoMapper::Document

  key :object_id, ObjectId
  key :kind, String
  key :unread, Boolean, :default => true

  belongs_to :user
  belongs_to :person

  timestamps!

  attr_accessible :object_id, :kind, :user_id, :person_id, :unread

  def self.for(user, opts={})
    self.where(opts.merge!(:user_id => user.id)).order('created_at desc')
  end

  def self.notify(user, object, person)
    if object.respond_to? :notification_type
      if kind = object.notification_type(user, person)
        Notification.create(:object_id => object.id, 
                            :kind => kind, 
                            :person_id => person.id, 
                            :user_id => user.id) 
       end
    end
  end
end
