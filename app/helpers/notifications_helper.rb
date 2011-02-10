module NotificationsHelper
  def object_link(note)
    target_type = note.action
    translation = t("notifications.#{target_type}")
    case target_type
    when 'mentioned'
      post = Mention.find(note.target_id).post
      if post
        "#{translation} #{link_to t('notifications.post'), object_path(post)}".html_safe
      else
        "#{translation} #{t('notifications.deleted')} #{t('notifications.post')}"
      end
    when 'request_accepted'
      translation
    when 'new_request'
      translation
    when 'comment_on_post'
      post = Post.where(:id => note.target_id).first
      if post
        "#{translation} #{link_to t('notifications.post'), object_path(post)}".html_safe
      else
        "#{translation} #{t('notifications.deleted')} #{t('notifications.post')}"
      end
    when 'also_commented'
      post = Post.where(:id => note.target_id).first
      if post
        "#{translation} #{link_to t('notifications.post'), object_path(post)}".html_safe
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

  def notification_people_link(note)
    note.actors.collect{ |person| link_to("#{h(person.name.titlecase)}", person_path(person))}.join(", ").html_safe
  end

  def peoples_names(note)
    note.actors.map{|p| p.name}.join(",")
  end
end
