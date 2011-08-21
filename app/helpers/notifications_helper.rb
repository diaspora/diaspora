module NotificationsHelper
  include ERB::Util
  include ActionView::Helpers::TranslationHelper
  include ActionView::Helpers::UrlHelper
  include PeopleHelper
  include UsersHelper
  include ApplicationHelper
  
  def object_link(note, actors)
    target_type = note.popup_translation_key
    actors_count = note.actors.count
    if note.instance_of?(Notifications::Mentioned)
      post = Mention.find(note.target_id).post
      if post
        translation(target_type, :actors => actors, :count => actors_count, :post_link => link_to(t('notifications.post'), post_path(post)).html_safe)
      else
        t('notifications.mentioned_deleted', :actors => actors, :count => actors_count).html_safe
      end
    elsif note.instance_of?(Notifications::CommentOnPost)
      post = Post.where(:id => note.target_id).first
      if post
        translation(target_type, :actors => actors, :count => actors_count, :post_link => link_to(t('notifications.post'), post_path(post), 'data-ref' => post.id, :class => 'hard_object_link').html_safe)
      else
        t('notifications.also_commented_deleted', :actors => actors, :count => actors_count).html_safe
      end
    elsif note.instance_of?(Notifications::AlsoCommented)
      post = Post.where(:id => note.target_id).first
      if post
        translation(target_type, :actors => actors, :count => actors_count, :post_author => h(post.author.name), :post_link => link_to(t('notifications.post'), post_path(post), 'data-ref' => post.id, :class => 'hard_object_link').html_safe)
      else
        t('notifications.also_commented_deleted', :actors => actors, :count => actors_count).html_safe
      end
    elsif note.instance_of?(Notifications::Liked)
      post = note.target
      post = post.target if post.is_a? Like
      if post
        translation(target_type, :actors => actors, :count => actors_count, :post_author => h(post.author.name), :post_link => link_to(t('notifications.post'), post_path(post), 'data-ref' => post.id, :class => 'hard_object_link').html_safe)
      else
        t('notifications.liked_post_deleted', :actors => actors, :count => actors_count).html_safe
      end
    else #Notifications:StartedSharing, etc.
      translation(target_type, :actors => actors, :count => actors_count)
    end
  end

  def translation(target_type, opts = {})
    {:post_author => nil}.merge!(opts)
    t("#{target_type}", opts).html_safe
  end


  def new_notification_link(count)
    if count > 0
        link_to new_notification_text(count), notifications_path
    end
  end

  def notification_people_link(note, people=nil)
    actors =people || note.actors
    number_of_actors = actors.count
    sentence_translations = {:two_words_connector => " #{t('notifications.index.and')} ", :last_word_connector => ", #{t('notifications.index.and')} " }
    actor_links = actors.collect{ |person|
      person_link(person, :class => 'hovercardable draggable_person', "data-person_id" => person.id )
    }

    if number_of_actors < 4
      message = actor_links.to_sentence(sentence_translations)
    else
      first, second, third, *others = actor_links
      others_sentence = others.to_sentence(sentence_translations)
      if others.count == 1
        others_sentence = " #{t('notifications.index.and')} " + others_sentence
      end
      message = "#{first}, #{second}, #{third},"
      message += "<a class='more' href='#'> #{t('notifications.index.and_others', :count =>(number_of_actors - 3))}</a>"
      message += "<span class='hidden'> #{others_sentence} </span>"
    end
    message.html_safe
  end

  def notification_message_for(note)
    object_link(note, notification_people_link(note))
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

