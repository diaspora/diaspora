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
    @posts ||= lambda do
      post_ids = aspect_posts_ids + followed_tag_ids + mentioned_post_ids
      post_ids += community_spotlight_post_ids if include_community_spotlight?
      Post.where(:id => post_ids).for_a_stream(max_time, order)
    end.call
  end

  def ajax_stream?
    false
  end

  private

  def include_community_spotlight?
    false
  end

  def aspect_posts_ids
    @aspect_posts_ids ||= user.visible_shareable_ids(Post, :limit => 15, :order => "#{order} DESC", :max_time => max_time, :all_aspects? => true, :by_members_of => aspect_ids)
  end

  def followed_tag_ids
    @followed_tag_ids ||= ids(StatusMessage.tag_stream(user, tag_array, max_time, order))
  end

  def mentioned_post_ids
    @mentioned_post_ids ||= ids(StatusMessage.where_person_is_mentioned(user.person).for_a_stream(max_time, order))
  end

  def community_spotlight_post_ids
    @community_spotlight_post_ids ||= ids(Post.all_public.where(:author_id => community_spotlight_person_ids).for_a_stream(max_time, order))
  end

  #worthless helpers
  def community_spotlight_person_ids
    Person.community_spotlight.select('id').map{|x| x.id}
  end

  def tag_array
    user.followed_tags.select('name').map{|x| x.name}
  end

  def ids(enumerable)
    Post.connection.select_values(enumerable.select('posts.id').to_sql)
  end
end
