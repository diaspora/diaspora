class Stream::Participate < Stream::Base
  def link(opts={})
    Rails.application.routes.url_helpers.participate_stream_path(opts)
  end

  def title
    I18n.translate("streams.participate.title")
  end

  # @return [ActiveRecord::Association<Post>] AR association of posts
  def posts
    @posts ||= EvilQuery::Participation.new(user).posts
  end

end