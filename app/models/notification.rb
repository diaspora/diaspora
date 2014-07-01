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
 
  def self.for(recipient, opts={})
    self.where(opts.merge!(:recipient_id => recipient.id)).order('updated_at desc')
  end

  def self.notify(recipient, target, actor)
    return nil unless target.respond_to? :notification_type

    note_type = target.notification_type(recipient, actor)
    return nil unless note_type

    return_note = if [Comment, Like, Reshare].any? { |klass| target.is_a?(klass) }
      s_target = target.is_a?(Reshare) ? target.root : target.parent
      note_type.concatenate_or_create(recipient, s_target,
                                          actor, note_type)
    else
      note_type.make_notification(recipient, target,
                                      actor, note_type)
    end
    return_note.email_the_user(target, actor) if return_note
    return_note 
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

  def self.types
    {
      "also_commented" => "Notifications::AlsoCommented",
      "comment_on_post" => "Notifications::CommentOnPost",
      "liked" => "Notifications::Liked",
      "mentioned" => "Notifications::Mentioned",
      "reshared" => "Notifications::Reshared",
      "started_sharing" => "Notifications::StartedSharing"
    }
  end
end
