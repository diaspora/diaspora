# frozen_string_literal: true

#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.
#
class Notification < ApplicationRecord
  include Diaspora::Fields::Guid

  belongs_to :recipient, class_name: "User"
  has_many :notification_actors, dependent: :delete_all
  has_many :actors, class_name: "Person", through: :notification_actors, source: :person
  belongs_to :target, polymorphic: true

  def self.for(recipient, opts={})
    where(opts.merge!(recipient_id: recipient.id)).order("updated_at DESC")
  end

  def set_read_state( read_state )
    update_column(:unread, !read_state)
  end

  def linked_object
    target
  end

  def self.concatenate_or_create(recipient, target, actor)
    return nil if suppress_notification?(recipient, actor)

    find_or_initialize_by(recipient: recipient, target: target, unread: true).tap do |notification|
      notification.actors |= [actor]
      # Explicitly touch the notification to update updated_at whenever new actor is inserted in notification.
      if notification.new_record? || notification.changed?
        notification.save!
      else
        notification.touch
      end
    end
  end

  def self.create_notification(recipient, target, actor)
    return nil if suppress_notification?(recipient, actor)

    create(recipient: recipient, target: target, actors: [actor])
  end

  private_class_method def self.suppress_notification?(recipient, actor)
    return true if recipient.blocks.exists?(person: actor)

    pref_name = NotificationService::NOTIFICATIONS_REVERSE_JSON_TYPES[name]
    NotificationSettingsService
      .new(recipient)
      .in_app_disabled?(pref_name)
  end
end
