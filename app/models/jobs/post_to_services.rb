module Jobs
  class PostToServices 
    @queue = :http_service
    def self.perform(user_id, post_id, url)
      user = User.find_by_id(user_id)
      post = Post.find_by_id(post_id)
      user.post_to_services(post, url)
    end
  end
end

