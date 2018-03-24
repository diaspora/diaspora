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
      participation:                participate?,
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

  def build_mentioned_people_json
    @post.mentioned_people.as_api_response(:backbone)
  end

  def build_photos_json
    @post.photos.map {|p| p.as_api_response(:backbone) }
  end

  def root
    if @post.respond_to?(:absolute_root) && @post.absolute_root.present?
      PostPresenter.new(@post.absolute_root, current_user).as_json
    end
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

  def user_like
    @post.like_for(current_user).try(:as_api_response, :backbone)
  end

  def user_reshare
    @post.reshare_for(current_user).try(:as_api_response, :backbone)
  end

  def poll_participation_answer_id
    @post.poll&.participation_answer(current_user)&.poll_answer_id if user_signed_in?
  end

  def participate?
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
end
