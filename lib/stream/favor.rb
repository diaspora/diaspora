class Stream::Favor < Stream::Base
  def link(opts={})
    Rails.application.routes.url_helpers.favor_stream_path(opts)
  end

  def title
    I18n.translate("streams.favors.title")
  end

  # @return [ActiveRecord::Association<Post>] AR association of posts
  def posts
    @posts ||= []
    Favorites.where(user_id: user.id).each do |f|
      @posts << f.post
    end
    @posts
  end

  def stream_posts
    self.posts
  end

  def contacts_title
    I18n.translate('streams.favors.contacts_title')
  end
end
