require File.join(File.dirname(__FILE__), '..', '..', 'lib', 'template_picker')

class PostPresenter
  attr_accessor :post, :current_user

  def initialize(post, current_user = nil)
    self.post = post
    self.current_user = current_user
  end

  def to_json(options = {})
    {
      :post => self.post.as_api_response(:backbone).update(
        {
        :user_like => self.user_like,
        :user_participation => self.user_participation,
        :user_reshare => self.user_reshare,
        :next_post => self.next_post_url,
        :previous_post => self.previous_post_url
      }),
      :templateName => TemplatePicker.new(self.post).template_name
    }
  end

  def user_like
    return unless self.current_user.present?
    if like = Like.where(:target_id => self.post.id, :target_type => "Post", :author_id => current_user.person.id).first
      like.as_api_response(:backbone)
    end
  end

  def user_participation
    return unless self.current_user.present?

    if participation = Participation.where(:target_id => self.post.id, :target_type => "Post", :author_id => current_user.person.id).first
      participation.as_api_response(:backbone)
    end
  end

  def user_reshare
    return unless self.current_user.present?
    Reshare.where(:root_guid => self.post.guid, :author_id => current_user.person.id).exists?
  end

  def next_post_url
    if n = next_post
      Rails.application.routes.url_helpers.post_path(n)
    end
  end

  def previous_post_url
    if p = previous_post
      Rails.application.routes.url_helpers.post_path(p)
    end
  end

  def next_post
    post_base.next(post)
  end

  def previous_post
    post_base.previous(post)
  end

  protected

  def post_base
    if current_user
      current_user.posts_from(self.post.author)
    else
      self.post.author.posts.all_public
    end
  end
end
