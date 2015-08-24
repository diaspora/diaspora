class PostPresenter < BasePresenter
  include PostsHelper

  attr_accessor :post

  def initialize(post, current_user=nil)
    @post = post
    @current_user = current_user
  end

  def as_json(_options={})
    @post.include_root_in_json = false
    @post.as_json(only: directly_retrieved_attributes).merge(non_directly_retrieved_attributes)
  end

  private

  def directly_retrieved_attributes
    %i(id guid public created_at interacted_at provider_display_name image_url object_url)
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
      already_participated_in_poll: already_participated_in_poll,
      participation:                participate?,
      interactions:                 build_interactions_json
    }
  end

  def build_text
    if @post.message
      @post.message.plain_text_for_json
    else
      @post.raw_message
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

  def title
    @post.message.present? ? @post.message.title : I18n.t("posts.presenter.title", name: @post.author_name)
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
    @post.reshare_for(current_user)
  end

  def already_participated_in_poll
    if @post.poll && user_signed_in?
      @post.poll.already_participated?(current_user)
    end
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
end
