#this file should go away, hence the name that is so full of lulz
#post interactions should probably be a decorator, and used in very few places... maybe?
class ExtremePostPresenter
  def initialize(post, current_user)
    @post = post
    @current_user = current_user
  end

  def as_json(options={})
    post = PostPresenter.new(@post, @current_user)
    interactions = PostInteractionPresenter.new(@post, @current_user)
    post.as_json.merge!(:interactions => interactions.as_json)
  end
end