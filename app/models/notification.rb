#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.
#
class Notification < ActiveRecord::Base
  require File.join(Rails.root, 'lib/diaspora/web_socket')
  include Diaspora::Socketable

  belongs_to :recipient, :class_name => 'User'
  has_many :notification_actors
  has_many :actors, :class_name => 'Person', :through => :notification_actors, :source => :person
  belongs_to :target, :polymorphic => true

  def self.for(recipient, opts={})
    self.where(opts.merge!(:recipient_id => recipient.id)).order('updated_at desc')
  end

  def self.notify(recipient, target, actor)
    if target.respond_to? :notification_type
      if note_type = target.notification_type(recipient, actor)
        if target.is_a? Comment
          n = note_type.concatenate_or_create(recipient, target.post, actor, note_type)
        else
          n = note_type.make_notification(recipient, target, actor, note_type)
        end
        n.email_the_user(target, actor) if n
        n.socket_to_user(recipient, :actor => actor) if n
        n
       end
    end
  end

  def email_the_user(target, actor)
    self.recipient.mail(self.mail_job, self.recipient_id, actor.id, target.id)
  end
  def mail_job
    raise NotImplementedError.new('Subclass this.')
  end

private
  def self.concatenate_or_create(recipient, target, actor, notification_type)
    if n = notification_type.where(:target_id => target.id,
                              :target_type => target.class.base_class,
                               :recipient_id => recipient.id).first
      unless n.actors.include?(actor)
        n.actors << actor
      end

      n.unread = true
      n.save!
      n
    else
      make_notification(recipient, target, actor, notification_type)
    end
  end

  def self.make_notification(recipient, target, actor, notification_type)
    n = notification_type.new(:target => target,
                               :recipient_id => recipient.id)
    n.actors << actor
    n.unread = false if target.is_a? Request
    n.save!
    n
  end
end
