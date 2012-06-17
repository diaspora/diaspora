#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.
#
class Notification < ActiveRecord::Base
  belongs_to :recipient, :class_name => 'User'
  has_many :notification_actors, :dependent => :destroy
  has_many :actors, :class_name => 'Person', :through => :notification_actors, :source => :person
  belongs_to :target, :polymorphic => true

  attr_accessor :note_html

  attr_accessible :target,
                  :target_id,
                  :target_type,
                  :type,
                  :unread,
                  :actors,
                  :recipient,
                  :recipient_id
 
  def self.for(recipient, opts={})
    self.where(opts.merge!(:recipient_id => recipient.id)).order('updated_at desc')
  end

  def self.notify(recipient, target, actor)
    if target.respond_to? :notification_type
      if note_type = target.notification_type(recipient, actor)
        if(target.is_a? Comment) || (target.is_a? Like)
          n = note_type.concatenate_or_create(recipient, target.parent, actor, note_type)
        elsif(target.is_a? Reshare)
          n = note_type.concatenate_or_create(recipient, target.root, actor, note_type)
        else
          n = note_type.make_notification(recipient, target, actor, note_type)
        end

        if n
          n.email_the_user(target, actor)
          n
        else
          nil
        end
       end
    end
  end

  def as_json(opts={})
    super(opts.merge(:methods => :note_html))
  end

  def email_the_user(target, actor)
    self.recipient.mail(self.mail_job, self.recipient_id, actor.id, target.id)
  end

  def set_read_state( read_state )
    self.update_attributes( :unread => !read_state )
  end

  def mail_job
    raise NotImplementedError.new('Subclass this.')
  end

  def effective_target
    self.popup_translation_key == "notifications.mentioned" ? self.target.post : self.target
  end

private
  def self.concatenate_or_create(recipient, target, actor, notification_type)
    return nil if suppress_notification?(recipient, target)

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


  def self.make_notification(recipient, target, actor, notification_type)
    return nil if suppress_notification?(recipient, target)
    n = notification_type.new(:target => target,
                              :recipient_id => recipient.id)
    n.actors = n.actors | [actor]
    n.unread = false if target.is_a? Request
    n.save!
    n
  end

  def self.suppress_notification?(recipient, post)
    post.is_a?(Post) && recipient.is_shareable_hidden?(post)
  end
end
