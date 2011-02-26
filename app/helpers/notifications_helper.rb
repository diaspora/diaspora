module NotificationsHelper
  def object_link(note)
    target_type = note.action
    case target_type
    when 'mentioned'
      post = Mention.find(note.target_id).post
      if post
        "#{translation(target_type)} #{link_to t('notifications.post'), object_path(post)}".html_safe
      else
        "#{translation(target_type)} #{t('notifications.deleted')} #{t('notifications.post')}"
      end
    when 'request_accepted'
      translation(target_type)
    when 'new_request'
      translation(target_type)
    when 'comment_on_post'
      post = Post.where(:id => note.target_id).first
      if post
        "#{translation(target_type)} #{link_to t('notifications.post'), object_path(post)}".html_safe
      else
        "#{translation(target_type)} #{t('notifications.deleted')} #{t('notifications.post')}"
      end
    when 'also_commented'
      post = Post.where(:id => note.target_id).first
      if post
        "#{translation(target_type, post.person.name)} #{link_to t('notifications.post'), object_path(post)}".html_safe
      else
        t('notifications.also_commented_deleted')
      end
    else
    end
  end

  def translation(target_type, post_author = nil)
    t("notifications.#{target_type}", :post_author => post_author)
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
