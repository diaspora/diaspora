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
        n.email_the_user(object) if n
        n.socket_to_uid(user) if n
        n
       end
    end
  end

  def email_the_user(object)
    case self.kind
    when "new_request"
      self.user.mail(Jobs::MailRequestReceived, self.user_id, self.person_id)
    when "request_accepted"
      self.user.mail(Jobs::MailRequestAcceptance, self.user_id, self.person_id)
    when "comment_on_post"
      self.user.mail(Jobs::MailCommentOnPost, self.user_id, self.person_id, object.id)
    when "also_commented"
      self.user.mail(Jobs::MailAlsoCommented, self.user_id, self.person_id, object.id)
    end
  end
end
