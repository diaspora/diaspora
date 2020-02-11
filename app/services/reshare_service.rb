# frozen_string_literal: true

class ReshareService
  def initialize(user=nil)
    @user = user
  end

  def create(post_id)
    post = post_service.find!(post_id)
    post = post.absolute_root if post.is_a? Reshare
    user.reshare!(post)
  end

  def find_for_post(post_id)
    reshares = post_service.find!(post_id).reshares
    user ? reshares.order(Arel.sql("author_id = #{user.person.id} DESC")) : reshares
  end

  private

  attr_reader :user

  def post_service
    @post_service ||= PostService.new(user)
  end
end
