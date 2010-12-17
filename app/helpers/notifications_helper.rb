module NotificationsHelper
  def glue_text(kind)
    translation = "notifications.#{kind.underscore}_glue"
    t(translation)
  end 

  def object_link(note)
    kind = note.kind.underscore
    translation = t("notifications.#{kind.underscore}_link")
    case kind
    when 'request'
     link_to translation, aspects_manage_path
    when 'status_message'
     link_to translation, status_message_path(note.object_id)
    when 'comment'
      link_to translation, object_path(Comment.first(:id => object_id).post)
    when 'photo'
      link_to translation, photo_path(note.object_id)
    else
    end
  end
end
