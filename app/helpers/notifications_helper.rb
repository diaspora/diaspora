module NotificationsHelper
  def object_link(note)
    kind = note.kind
    translation = t("notifications.#{kind}")
    case kind
    when 'request_accepted'
      translation
    when 'new_request'
      translation
    when 'comment_on_post'
       "#{translation} #{link_to t('notifications.post'), object_path(Comment.first(:id => note.object_id).post)}".html_safe
    else
    end
  end
end
