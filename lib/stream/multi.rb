class Stream::Multi < Stream::Base

  # @return [String] URL
  def link(opts)
    Rails.application.routes.url_helpers.multi_stream_path(opts)
  end

  # @return [String]
  def title
    I18n.t('streams.multi.title')
  end

  # @return [String]
  def contacts_title
    I18n.t('streams.multi.contacts_title')
  end

  def posts
    @posts ||= lambda do
      post_ids = aspects_post_ids + followed_tags_post_ids + mentioned_post_ids
      post_ids += community_spotlight_post_ids if include_community_spotlight?
      Post.where(:id => post_ids)
    end.call
  end

  #emits an enum of the groups which the post appeared
  # :spotlight, :aspects, :tags, :mentioned
  def post_from_group(post)
    streams_included.collect do |source|
      is_in?(source, post)
    end.compact
  end

  private
  def publisher_opts
    if welcome?
      {:open => true, :prefill => publisher_prefill, :public => true}
    else
      super
    end
  end

  # Generates the prefill for the publisher
  #
  # @return [String]
  def publisher_prefill
    prefill = I18n.t("shared.publisher.new_user_prefill.hello", :new_user_tag => I18n.t('shared.publisher.new_user_prefill.newhere'))
    if self.user.followed_tags.size > 0
      tag_string = self.user.followed_tags.map{|t| "##{t.name}"}.to_sentence
      prefill << I18n.t("shared.publisher.new_user_prefill.i_like", :tags => tag_string)
    end

    if inviter = self.user.invited_by.try(:person)
      prefill << I18n.t("shared.publisher.new_user_prefill.invited_by")
      prefill << "@{#{inviter.name} ; #{inviter.diaspora_handle}}!"
    end

    prefill
  end

  # @return [Boolean]
  def welcome?
    self.user.getting_started
  end

  # @return [Array<Symbol>]
  def streams_included
    @streams_included ||= lambda do
      array = [:mentioned, :aspects, :followed_tags]
      array << :community_spotlight if include_community_spotlight?
      array
    end.call
  end

  # @return [Symbol]
  def is_in?(sym, post)
    if self.send("#{sym.to_s}_post_ids").find{|x| (x == post.id) || (x.to_s == post.id.to_s)}
      "#{sym.to_s}_stream".to_sym
    end
  end

  # @return [Boolean]
  def include_community_spotlight?
    AppConfig[:community_spotlight].present? && user.show_community_spotlight_in_stream?
  end

  def aspects_post_ids
    @aspects_post_ids ||= user.visible_shareable_ids(Post, :limit => 15, :order => "#{order} DESC", :max_time => max_time, :all_aspects? => true, :by_members_of => aspect_ids)
  end

  def followed_tags_post_ids
    @followed_tags_ids ||= ids(StatusMessage.public_tag_stream(tag_ids))
  end

  def mentioned_post_ids
    @mentioned_post_ids ||= ids(StatusMessage.where_person_is_mentioned(user.person))
  end

  def community_spotlight_post_ids
    @community_spotlight_post_ids ||= ids(Post.all_public.where(:author_id => community_spotlight_person_ids))
  end

  #worthless helpers
  def community_spotlight_person_ids
    @community_spotlight_person_ids ||= Person.community_spotlight.select('id').map{|x| x.id}
  end

  def tag_ids
    user.followed_tags.map{|x| x.id}
  end

  def ids(query)
    Post.connection.select_values(query.for_a_stream(max_time, order).select('posts.id').to_sql)
  end

end
