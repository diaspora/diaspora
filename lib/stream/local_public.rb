# frozen_string_literal: true

# rubocop:disable Style/ClassAndModuleChildren
class Stream::LocalPublic < Stream::Base
  def link(opts={})
    Rails.application.routes.url_helpers.local_public_stream_path(opts)
  end

  def title
    I18n.t("streams.local_public.title")
  end

  # @return [ActiveRecord::Association<Post>] AR association of posts
  def posts
    @posts ||= Post.all_local_public
  end

  # Override base class method
  def aspects
    ["public"]
  end
end
# rubocop:enable Style/ClassAndModuleChildren
