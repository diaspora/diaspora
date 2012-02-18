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
        { :next_post => next_post_url,
      :previous_post => previous_post_url}),
      :templateName => TemplatePicker.new(self.post).template_name
    }
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
    post_base.next(post).first
  end

  def previous_post
    post_base.previous(post).first
  end

  protected

  def post_base 
    scope = if current_user
      Post.owned_or_visible_by_user(current_user)
    else
      Post.all_public
    end
    scope.where(:author_id => post.author_id)
  end
end