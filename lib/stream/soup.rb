class Stream::Soup < Stream::Base
  def link(opts)
    Rails.application.routes.url_helpers.soup_path
  end

  def title
    I18n.t('streams.soup.title')
  end

  def contacts_title
    I18n.t('streams.soup.contacts_title')
  end

  def posts
    post_ids = aspect_posts_ids + followed_tag_ids + mentioned_post_ids
    post_ids += featured_user_post_ids
    Post.where(:id => post_ids).for_a_stream(max_time, order)
  end

  private

  def aspect_posts_ids
    user.visible_post_ids(:limit => 15, :order => order, :max_time => max_time)
  end

  def followed_tag_ids
    StatusMessage.tag_stream(user, tag_array, max_time, order).map{|x| x.id}
  end

  def mentioned_post_ids
    ids(StatusMessage.where_person_is_mentioned(user.person).for_a_stream(max_time, order))
  end

  def featured_user_post_ids
    ids(Post.all_public.where(:author_id => featured_user_ids).for_a_stream(max_time, order))
  end

  #worthless helpers
  def featured_user_ids
    ids(Person.featured_users)
  end

  def tag_array
    user.followed_tags.map{|x| x.name}
  end
  
  def ids(enumerable)
    enumerable.map{|x| x.id}
  end
end
