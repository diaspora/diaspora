class Stream::Bookmarked < Stream::Base
  def link(opts={})
    Rails.application.routes.url_helpers.bookmarked_stream_path(opts)
  end

  def title
    I18n.translate("streams.bookmarks.title")
  end

  # @return [ActiveRecord::Association<Post>] AR association of posts
  def posts
    @posts ||= []
    Bookmarks.where(user_id: user.id).each do |f|
      @posts << f.post
    end
    @posts
  end

  def stream_posts
    self.posts
  end

  def contacts_title
    I18n.translate('streams.bookmarks.contacts_title')
  end
end
