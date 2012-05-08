require File.join(File.dirname(__FILE__), '..', '..', 'lib', 'template_picker')

class PostPresenter
  attr_accessor :post, :current_user

  def initialize(post, current_user = nil)
    @post = post
    @current_user = current_user
  end

  def to_json(options = {})
    @post.as_api_response(:backbone).update(
        {
        :user_like => user_like,
        :user_participation => user_participation,
        :likes_count => @post.likes.count,
        :participations_count => @post.participations.count,
        :reshares_count => @post.reshares.count,
        :user_reshare => user_reshare,
        :next_post => next_post_path,
        :previous_post => previous_post_path,
        :likes => likes,
        :reshares => reshares,
        :comments => comments,
        :participations => participations,
        :frame_name => @post.frame_name || template_name,
        :title => title
      })
  end

  def next_post_path
    Rails.application.routes.url_helpers.next_post_path(@post)
  end

  def previous_post_path
    Rails.application.routes.url_helpers.previous_post_path(@post)
  end

  def comments
    as_api(@post.comments)
  end

  def likes
    as_api(@post.likes)
  end

  def reshares
    as_api(@post.reshares)
  end

  def participations
    as_api(@post.participations)
  end

  def user_like
    return unless user_signed_in?
    @post.likes.where(:author_id => person.id).first.try(:as_api_response, :backbone)
  end

  def user_participation
    return unless user_signed_in?
    @post.participations.where(:author_id => person.id).first.try(:as_api_response, :backbone)
  end

  def user_reshare
    return unless user_signed_in?
    @post.reshares.where(:author_id => person.id).first
  end

  def title
    if @post.text.present?
      @post.text(:plain_text => true)
    else
      I18n.translate('posts.presenter.title', :name => @post.author.name)
    end  
  end

  def template_name #kill me, lol, I should be client side
    @template_name ||= TemplatePicker.new(@post).template_name
  end

  protected

  def as_api(collection)
    collection.includes(:author => :profile).all.map do |element|
      element.as_api_response(:backbone)
    end
  end

  def person
    @current_user.person
  end

  def user_signed_in?
    @current_user.present?
  end
end
