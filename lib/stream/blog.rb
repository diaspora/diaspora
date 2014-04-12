class Stream::Blog < Stream::Base
  def link(opts={})
    Rails.application.routes.url_helpers.blog_streams_path(opts)
  end

  def order
    "interacted_at"
  end

  def title
    I18n.translate("streams.blog.title")
  end

  # @return [ActiveRecord::Association<Post>] AR association of posts
  def posts
    @posts ||= EvilQuery::Blog.new(user).posts
    #binding.pry
  end
end