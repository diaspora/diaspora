class LikeService
  def initialize(user=nil)
    @user = user
  end

  def create(post_id)
    post = post_service.find!(post_id)
    user.like!(post)
  end

  def destroy(like_id)
    like = Like.find(like_id)
    if user.owns?(like)
      user.retract(like)
      true
    else
      false
    end
  end

  def find_for_post(post_id)
    likes = post_service.find!(post_id).likes
    user ? likes.order("author_id = #{user.person.id} DESC") : likes
  end

  private

  attr_reader :user

  def post_service
    @post_service ||= PostService.new(user)
  end
end
