#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.
#
class Notification < ActiveRecord::Base
  require File.join(Rails.root, 'lib/diaspora/web_socket')
  include Diaspora::Socketable

  belongs_to :recipient, :class_name => 'User'
  has_many :notification_actors, :dependent => :destroy
  has_many :actors, :class_name => 'Person', :through => :notification_actors, :source => :person
  belongs_to :target, :polymorphic => true

  def self.for(recipient, opts={})
    self.where(opts.merge!(:recipient_id => recipient.id)).order('updated_at desc')
  end

  def self.notify(recipient, target, actor)
    if target.respond_to? :notification_type
      if action = target.notification_type(recipient, actor)
        if target.is_a? Comment
          n = concatenate_or_create(recipient, target.post, actor, action)
        else
          n = make_notification(recipient, target, actor, action)
        end
        n.email_the_user(target, actor) if n
        n.socket_to_user(recipient, :actor => actor) if n
        n
       end
    end
  end

  def email_the_user(target, actor)
    case self.action
    when "new_request"
      self.recipient.mail(Job::MailRequestReceived, self.recipient_id, actor.id)
    when "request_accepted"
      self.recipient.mail(Job::MailRequestAcceptance, self.recipient_id, actor.id)
    when "comment_on_post"
      self.recipient.mail(Job::MailCommentOnPost, self.recipient_id, actor.id, target.id)
    when "also_commented"
      self.recipient.mail(Job::MailAlsoCommented, self.recipient_id, actor.id, target.id)
    when "mentioned"
      self.recipient.mail(Job::MailMentioned, self.recipient_id, actor.id, target.id)
    end
  end

private
  def self.concatenate_or_create(recipient, target, actor, action)
    if n = Notification.where(:target_id => target.id,
                              :target_type => target.class.base_class,
                               :action => action,
                               :recipient_id => recipient.id).first
      unless n.actors.include?(actor)
        n.actors << actor
      end

      n.unread = true
      n.save!
      n
    else
      make_notification(recipient, target, actor, action)
    end
  end

  def self.make_notification(recipient, target, actor, action)
    n = Notification.new(:target => target,
                               :action => action,
                               :recipient_id => recipient.id)
    n.actors << actor
    n.unread = false if target.is_a? Request
    n.save!
    n
  end
end
