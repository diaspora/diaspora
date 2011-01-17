module NotificationsHelper
  def object_link(note)
    target_type = note.action
    translation = t("notifications.#{target_type}")
    case target_type
    when 'request_accepted'
      translation
    when 'new_request'
      translation
    when 'comment_on_post'
      comment = Comment.where(:id => note.target_id).first
      if comment
       "#{translation} #{link_to t('notifications.post'), object_path(comment.post)}".html_safe
      else
        "#{translation} #{t('notifications.deleted')} #{t('notifications.post')}"
      end
    when 'also_commented'
      comment = Comment.where(:id => note.target_id).first
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

  def new_notification_link(count)
    if count > 0
        link_to new_notification_text(count), notifications_path
    end
  end
end
