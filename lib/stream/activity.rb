class Stream::Activity < Stream::Base
  def link(opts={})
    Rails.application.routes.url_helpers.activity_streams_path(opts)
  end

  def order
    {:primary => "interacted_at", :secondary => "#{Participation.table_name}.id"}
  end

  def title
    I18n.translate("streams.activity.title")
  end

  # @return [ActiveRecord::Association<Post>] AR association of posts
  def posts
    @posts ||= EvilQuery::Participation.new(user).posts
  end
end
