# frozen_string_literal: true

class NotificationSerializer < ActiveModel::Serializer
  attributes :id,
             :target_type,
             :target_id,
             :recipient_id,
             :unread,
             :created_at,
             :updated_at,
             :note_html

  def note_html
    context.render_to_string(partial: "notifications/notification", locals: {note: object, no_aspect_dropdown: true})
  end

  def initialize(*_)
    super
    self.polymorphic = true
    self.root = false
  end
end
