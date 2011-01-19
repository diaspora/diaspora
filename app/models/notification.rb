#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.
#
class Notification < ActiveRecord::Base
  require File.join(Rails.root, 'lib/diaspora/web_socket')
  include Diaspora::Socketable

  belongs_to :recipient, :class_name => 'User'
  belongs_to :actor, :class_name => 'Person'
  belongs_to :target, :polymorphic => true

  def self.for(recipient, opts={})
    self.where(opts.merge!(:recipient_id => recipient.id)).order('created_at desc')
  end

  def self.notify(recipient, target, actor)
    if target.respond_to? :notification_type
      if action = target.notification_type(recipient, actor)
        n = create(:target => target,
               :action => action,
               :actor => actor,
               :recipient => recipient)
        n.email_the_user if n
        n.socket_to_user(recipient) if n
        n
       end
    end
  end

  def email_the_user
    case self.action
    when "new_request"
      self.recipient.mail(Job::MailRequestReceived, self.recipient_id, self.actor_id)
    when "request_accepted"
      self.recipient.mail(Job::MailRequestAcceptance, self.recipient_id, self.actor_id)
    when "comment_on_post"
      self.recipient.mail(Job::MailCommentOnPost, self.recipient_id, self.actor_id, target.id)
    when "also_commented"
      self.recipient.mail(Job::MailAlsoCommented, self.recipient_id, self.actor_id, target.id)
    end
  end
end
