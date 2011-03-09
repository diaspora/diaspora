module NotificationsHelper
  def object_link(note)
    target_type = note.translation_key
    if note.instance_of?(Notifications::Mentioned)
      post = Mention.find(note.target_id).post
      if post
        "#{translation(target_type)} #{link_to t('notifications.post'), object_path(post)}".html_safe
      else
        "#{translation(target_type)} #{t('notifications.deleted')} #{t('notifications.post')}"
      end
    elsif note.instance_of?(Notifications::RequestAccepted)
      translation(target_type)
    elsif note.instance_of?(Notifications::NewRequest)
      translation(target_type)
    elsif note.instance_of?(Notifications::CommentOnPost)
      post = Post.where(:id => note.target_id).first
      if post
        "#{translation(target_type)} #{link_to t('notifications.post'), object_path(post)}".html_safe
      else
        "#{translation(target_type)} #{t('notifications.deleted')} #{t('notifications.post')}"
      end
    elsif note.instance_of?(Notifications::AlsoCommented)
      post = Post.where(:id => note.target_id).first
      if post
        "#{translation(target_type, post.author.name)} #{link_to t('notifications.post'), object_path(post)}".html_safe
      else
        t('notifications.also_commented_deleted')
      end
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
