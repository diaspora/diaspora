class PostPresenter
  include PostsHelper

  attr_accessor :post, :current_user

  def initialize(post, current_user = nil)
    @post = post
    @current_user = current_user
  end

  def self.collection_json(collection, current_user)
    collection.map {|post| PostPresenter.new(post, current_user)}
  end

  def as_json(options={})
    text = if @post.message
      @post.message.plain_text_for_json
    else
      @post.raw_message
    end
    {
        :id => @post.id,
        :guid => @post.guid,
        :text => text,
        :public => @post.public,
        :created_at => @post.created_at,
        :interacted_at => @post.interacted_at,
        :provider_display_name => @post.provider_display_name,
        :post_type => @post.post_type,
        :image_url => @post.image_url,
        :object_url => @post.object_url,
        :nsfw => @post.nsfw,
        :author => @post.author.as_api_response(:backbone),
        :o_embed_cache => @post.o_embed_cache.try(:as_api_response, :backbone),
        :open_graph_cache => @post.open_graph_cache.try(:as_api_response, :backbone),
        :mentioned_people => @post.mentioned_people.as_api_response(:backbone),
        :photos => @post.photos.map {|p| p.as_api_response(:backbone)},
        :root => root,
        :title => title,
        :address => @post.address,
        :poll => @post.poll(),
        :already_participated_in_poll => already_participated_in_poll,
        :participation => participate?,

        :interactions => {
            :likes => [user_like].compact,
            :reshares => [user_reshare].compact,
            :comments_count => @post.comments_count,
            :likes_count => @post.likes_count,
            :reshares_count => @post.reshares_count
        }
    }
  end

  def title
    @post.message.present? ? @post.message.title : I18n.t('posts.presenter.title', name: @post.author_name)
  end

  def root
    PostPresenter.new(@post.absolute_root, current_user).as_json if @post.respond_to?(:absolute_root) && @post.absolute_root.present?
  end

  def user_like
    @post.like_for(@current_user).try(:as_api_response, :backbone)
  end

  def user_reshare
    @post.reshare_for(@current_user)
  end

  protected

  def person
    @current_user.person
  end

  def user_signed_in?
    @current_user.present?
  end

  private

  def already_participated_in_poll
    if @post.poll && user_signed_in?
      @post.poll.already_participated?(current_user)
    end
  end

  def participate?
    user_signed_in? && @current_user.participations.where(:target_id => @post).exists?
  end

end
