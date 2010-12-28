module NotificationsHelper
  def object_link(note)
    target_type = note.target_type
    translation = t("notifications.#{target_type}")
    case target_type
    when 'request_accepted'
      translation
    when 'new_request'
      translation
    when 'comment_on_post'
      comment = Comment.first(:id => note.target_id)
      if comment
       "#{translation} #{link_to t('notifications.post'), object_path(comment.post)}".html_safe
      else
        "#{translation} #{t('notifications.deleted')} #{t('notifications.post')}"
      end
    else
    end
  end

  def new_notification_text(count)
    if count > 0
      t('new_notifications', :count => count)
    else
      t('no_new_notifications')
    end
  end
end
