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
    self.where(opts.merge!(:recipient_id => recipient.id, :blocker => false)).order('updated_at desc')
  end

  def self.notify(recipient, target, actor)
    return nil unless target.respond_to? :notification_type

    if note_type = target.notification_type(recipient, actor)
      note_target = notification_target_for(target)
      if(target.is_a? Comment) || (target.is_a? Like) || (target.is_a? Reshare)
        return nil unless recipient.wants_to_be_notified_for?(note_target, note_type)
        n = note_type.concatenate_or_create(recipient, note_target, actor, note_type)
      else
        n = note_type.make_notification(recipient, note_target, actor, note_type)
      end
      n.email_the_user(target, actor) if n
      n.socket_to_user(recipient, :actor => actor) if n
      n
    end
  end

  def self.block(recipient, target, notification_types)
    note_target = notification_target_for(target)
    return unless recipient.wants_to_be_notified_for?(note_target, notification_types)

    notification_types = [notification_types] unless notification_types.is_a? Array
    notification_types.each do |type|
      self.make_notification(recipient, note_target, recipient.person, type, :block_notification => true, :unread => false)
    end
  end

  def self.unblock(recipient, target, notification_types)
    notification_types = [notification_types] unless notification_types.is_a? Array
    target = notification_target_for(target)

    Notification.delete_all(:recipient_id => recipient.id,
                            :type => notification_types.collect {|t| t.to_s},
                            :target_id => target.id,
                            :target_type => target.class.base_class.to_s,
                            :blocker => true)
  end

  def email_the_user(target, actor)
    self.recipient.mail(self.mail_job, self.recipient_id, actor.id, target.id)
  end


  def mail_job
    raise NotImplementedError.new('Subclass this.')
  end

  def self.notification_target_for(target)
    if(target.is_a? Comment) || (target.is_a? Like)
      target.parent
    elsif(target.is_a? Reshare)
      target.root
    else
      target
    end
  end

private
  def self.concatenate_or_create(recipient, target, actor, notification_type)
    if n = notification_type.where(:target_id => target.id,
                                   :target_type => target.class.base_class,
                                   :recipient_id => recipient.id,
                                   :unread => true).first

      begin
        n.actors = n.actors | [actor]
        n.unread = true
        n.save!
      rescue ActiveRecord::RecordNotUnique
        nil
      end
      n
    else
      make_notification(recipient, target, actor, notification_type)
    end
  end

  def self.make_notification(recipient, target, actor, notification_type, opts={})
    opts[:block_notification] ||= false;

    n = notification_type.new(:target => target,
                              :recipient_id => recipient.id)
    n.actors = n.actors | [actor]
    n.unread = false if target.is_a? Request
    n.unread = opts[:unread] if opts.has_key?(:unread)
    n.blocker = opts[:block_notification]
    n.save!
    n
  end
end
