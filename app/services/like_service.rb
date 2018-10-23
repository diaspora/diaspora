# frozen_string_literal: true

class LikeService
  def initialize(user=nil)
    @user = user
  end

  def create_for_post(post_id)
    post = post_service.find!(post_id)
    user.like!(post)
  end

  def create_for_comment(comment_id)
    comment = comment_service.find!(comment_id)
    user.like!(comment)
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
    user ? likes.order(Arel.sql("author_id = #{user.person.id} DESC")) : likes
  end

  def unlike_post(post_id)
    likes = post_service.find!(post_id).likes
    likes = likes.order(Arel.sql("author_id = #{user.person.id} DESC"))
    if !likes.empty? && user.owns?(likes[0])
      user.retract(likes[0])
      true
    else
      false
    end
  end

  private

  attr_reader :user

  def post_service
    @post_service ||= PostService.new(user)
  end

  def comment_service
    @comment_service ||= CommentService.new(user)
  end
end
