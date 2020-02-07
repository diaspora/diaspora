# frozen_string_literal: true

class PostPresenter < BasePresenter
  include PostsHelper
  include MetaDataHelper

  attr_accessor :post

  def initialize(presentable, current_user=nil)
    @post = presentable
    super
  end

  def as_json(_options={})
    @post.as_json(only: directly_retrieved_attributes)
         .merge(non_directly_retrieved_attributes)
  end

  def as_api_response # rubocop:disable Metrics/AbcSize
    {
      guid:                  @post.guid,
      body:                  build_text,
      title:                 title,
      post_type:             @post.post_type,
      public:                @post.public,
      created_at:            @post.created_at,
      nsfw:                  @post.nsfw,
      author:                PersonPresenter.new(@post.author).as_api_json,
      provider_display_name: @post.provider_display_name,
      interaction_counters:  PostInteractionPresenter.new(@post, current_user).as_counters,
      location:              location_as_api_json,
      poll:                  PollPresenter.new(@post.poll, current_user).as_api_json,
      mentioned_people:      build_mentioned_people_json,
      photos:                build_photos_json,
      root:                  root_api_response,
      own_interaction_state: build_own_interaction_state,
      open_graph_object:     open_graph_object_api_response,
      oembed:                @post.o_embed_cache.try(:data)
    }.compact
  end

  def with_interactions
    interactions = PostInteractionPresenter.new(@post, current_user)
    as_json.merge!(interactions: interactions.as_json)
  end

  def with_initial_interactions
    as_json.tap do |post|
      post[:interactions].merge!(
        likes:    LikeService.new(current_user).find_for_post(@post.id).limit(30).as_api_response(:backbone),
        reshares: ReshareService.new(current_user).find_for_post(@post.id).limit(30).as_api_response(:backbone)
      )
    end
  end

  def metas_attributes
    {
      keywords:             {name:     "keywords",       content: comma_separated_tags},
      description:          {name:     "description",    content: description},
      og_url:               {property: "og:url",         content: url},
      og_title:             {property: "og:title",       content: title},
      og_image:             {property: "og:image",       content: images},
      og_description:       {property: "og:description", content: description},
      og_article_tag:       {property: "og:article:tag", content: tags},
      og_article_author:    {property: "og:article:author",         content: author_name},
      og_article_modified:  {property: "og:article:modified_time",  content: modified_time_iso8601},
      og_article_published: {property: "og:article:published_time", content: published_time_iso8601}
    }
  end

  def page_title
    post_page_title @post
  end

  private

  def directly_retrieved_attributes
    %i(id guid public created_at interacted_at provider_display_name)
  end

  def non_directly_retrieved_attributes
    {
      text:                         build_text,
      post_type:                    @post.post_type,
      nsfw:                         @post.nsfw,
      author:                       @post.author.as_api_response(:backbone),
      o_embed_cache:                @post.o_embed_cache.try(:as_api_response, :backbone),
      open_graph_cache:             build_open_graph_cache,
      mentioned_people:             build_mentioned_people_json,
      photos:                       build_photos_json,
      root:                         root,
      title:                        title,
      location:                     @post.post_location,
      poll:                         @post.poll,
      poll_participation_answer_id: poll_participation_answer_id,
      participation:                participates?,
      interactions:                 build_interactions_json
    }
  end

  def title
    @post.message.present? ? @post.message.title : I18n.t("posts.presenter.title", name: @post.author_name)
  end

  def build_text
    if @post.message
      @post.message.plain_text_for_json
    else
      @post.text
    end
  end

  def build_open_graph_cache
    @post.open_graph_cache.try(:as_api_response, :backbone)
  end

  def open_graph_object_api_response
    cache = @post.open_graph_cache
    return unless cache

    {
      type:        cache.ob_type,
      url:         cache.url,
      title:       cache.title,
      image:       cache.image,
      description: cache.description,
      video_url:   cache.video_url
    }
  end

  def build_mentioned_people_json
    @post.mentioned_people.map {|m| PersonPresenter.new(m).as_api_json }
  end

  def build_photos_json
    @post.photos.map {|p| PhotoPresenter.new(p).as_api_json }
  end

  def root
    if @post.respond_to?(:absolute_root) && @post.absolute_root.present?
      PostPresenter.new(@post.absolute_root, current_user).as_json
    end
  end

  def root_api_response
    is_root_post_exist = @post.respond_to?(:absolute_root) && @post.absolute_root.present?
    PostPresenter.new(@post.absolute_root, current_user).as_api_response if is_root_post_exist
  end

  def build_interactions_json
    {
      likes:          [user_like].compact,
      reshares:       [user_reshare].compact,
      comments_count: @post.comments_count,
      likes_count:    @post.likes_count,
      reshares_count: @post.reshares_count
    }
  end

  def build_own_interaction_state
    if current_user
      {
        liked:      @post.likes.where(author: current_user.person).exists?,
        reshared:   @post.reshares.where(author: current_user.person).exists?,
        subscribed: participates?,
        reported:   @post.reports.where(user: current_user).exists?
      }
    else
      {
        liked:      false,
        reshared:   false,
        subscribed: false,
        reported:   false
      }
    end
  end

  def user_like
    @post.like_for(current_user).try(:as_api_response, :backbone)
  end

  def user_reshare
    @post.reshare_for(current_user).try(:as_api_response, :backbone)
  end

  def poll_participation_answer_id
    @post.poll&.participation_answer(current_user)&.poll_answer_id if user_signed_in?
  end

  def participates?
    user_signed_in? && current_user.participations.where(target_id: @post).exists?
  end

  def user_signed_in?
    current_user.present?
  end

  def person
    current_user.person
  end

  def images
    photos.any? ? photos.map(&:url) : default_image_url
  end

  def published_time_iso8601
    created_at.to_time.iso8601
  end

  def modified_time_iso8601
    updated_at.to_time.iso8601
  end

  def tags
    tags = @post.is_a?(Reshare) ? @post.absolute_root.try(:tags) : @post.tags
    tags ? tags.map(&:name) : []
  end

  def comma_separated_tags
    tags.join(", ")
  end

  def url
    post_url @post
  end

  def description
    message.try(:plain_text_without_markdown, truncate: 1000)
  end

  def location_as_api_json
    location = @post.post_location
    return if location.values.all?(&:nil?)

    location[:lat] = location[:lat].to_f
    location[:lng] = location[:lng].to_f
    location
  end
end
