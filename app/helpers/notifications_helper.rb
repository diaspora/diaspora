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
        "#{translation(target_type)} #{link_to t('notifications.post'), object_path(post), 'data-ref' => post.id, :class => 'hard_object_link'}".html_safe
      else
        "#{translation(target_type)} #{t('notifications.deleted')} #{t('notifications.post')}"
      end
    elsif note.instance_of?(Notifications::AlsoCommented)
      post = Post.where(:id => note.target_id).first
      if post
        "#{translation(target_type, post.author.name)} #{link_to t('notifications.post'), object_path(post), 'data-ref' => post.id, :class => 'hard_object_link'}".html_safe
      else
        t('notifications.also_commented_deleted')
      end
    end
  end

  def translation(target_type, post_author = nil)
    t("notifications.#{target_type}", :post_author => post_author)
  end


  def new_notification_link(count)
    if count > 0
        link_to new_notification_text(count), notifications_path
    end
  end

  def notification_people_link(note)
    actors = note.actors
    number_of_actors = actors.count
    actor_links = actors.collect{ |person| link_to("#{h(person.name.titlecase)}", person_path(person))}
    if number_of_actors < 4
      message =  actor_links.join(', ')
    else
      message  = actor_links[0..2].join(', ') << "<a class='more' href='#'> #{t('.and_others', :number =>(number_of_actors - 3))}</a><span class='hidden'>, " << actor_links[3..(number_of_actors-2)].join(', ')<< " #{t('.and')} "<< actor_links.last << '</span>'
    end
    message.html_safe
  end

  def peoples_names(note)
    note.actors.map{|p| p.name}.join(", ")
  end

  def the_day(i18n)
    i18n[0].match(/\d/) ? i18n[0].gsub('.', '') : i18n[1].gsub('.', '')
  end

  def the_month(i18n)
    i18n[0].match(/\d/) ? i18n[1] : i18n[0]
  end
end
