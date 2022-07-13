# frozen_string_literal: true

module NotifierHelper
  include PostsHelper

  # @param post [Post] The post object.
  # @param opts [Hash] Optional hash.  Accepts :html parameter.
  # @return [String] The formatted post.
  def post_message(post, opts={})
    rendered = opts[:html] ? post.message&.markdownified_for_mail : post.message&.plain_text_without_markdown
    rendered.presence || post_page_title(post)
  end

  # @param comment [Comment] The comment to process.
  # @param opts [Hash] Optional hash.  Accepts :html parameter.
  # @return [String] The formatted comment.
  def comment_message(comment, opts={})
    if comment.post.public?
      opts[:html] ? comment.message.markdownified_for_mail : comment.message.plain_text_without_markdown
    else
      I18n.translate "notifier.a_limited_post_comment"
    end
  end
end
