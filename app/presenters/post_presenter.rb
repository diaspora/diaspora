require File.join(File.dirname(__FILE__), '..', '..', 'lib', 'template_picker')

class PostPresenter
  attr_accessor :post, :current_user

  def initialize(post, current_user = nil)
    self.post = post
    self.current_user = current_user
  end

  def to_json(options = {})
    self.post.as_api_response(:backbone).update(
        {
        :user_like => self.user_like,
        :user_participation => self.user_participation,
        :likes_count => self.post.likes.count,
        :participations_count => self.post.participations.count,
        :reshares_count => self.post.reshares.count,
        :user_reshare => self.user_reshare,
        :next_post => self.next_post_path,
        :previous_post => self.previous_post_path,
        :likes => self.likes,
        :reshares => self.reshares,
        :comments => self.comments,
        :participations => self.participations,
        :templateName => template_name,
        :title => title
      })
  end

  def comments
    as_api(post.comments)
  end

  def likes
    as_api(post.likes)
  end

  def reshares
    as_api(post.reshares)
  end

  def participations
    as_api(post.participations)
  end


  def user_like
    return unless user_signed_in?
    if like = post.likes.where(:author_id => person.id).first
      like.as_api_response(:backbone)
    end
  end

  def user_participation
    return unless user_signed_in?
    if participation = post.participations.where(:author_id => person.id).first
      participation.as_api_response(:backbone)
    end
  end

  def user_reshare
    return unless user_signed_in?
    self.post.reshares.where(:author_id => person.id).first
  end

  def next_post_path
    if n = next_post
      Rails.application.routes.url_helpers.post_path(n)
    end
  end

  def previous_post_path
    if p = previous_post
      Rails.application.routes.url_helpers.post_path(p)
    end
  end

  def title
    if post.text.present?
      post.text(:plain_text => true)
    else
      I18n.translate('posts.presenter.title', :name => post.author.name)
    end  
  end

  def template_name
    @template_name ||= TemplatePicker.new(post).template_name
  end

  protected

  def next_post
    post_base.next(post)
  end

  def previous_post
    post_base.previous(post)
  end

  def as_api(collection)
    collection.includes(:author => :profile).all.map do |element|
      element.as_api_response(:backbone)
    end
  end

  def post_base
    Post.visible_from_author(self.post.author, current_user)
  end

  def person
    self.current_user.person
  end

  def user_signed_in?
    current_user.present?
  end

end
