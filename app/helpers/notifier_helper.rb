# frozen_string_literal: true

module NotifierHelper

  # @param post [Post] The post object.
  # @param opts [Hash] Optional hash.  Accepts :length parameters.
  # @return [String] The formatted post.
  def post_message(post, opts={})
    if post.respond_to? :message
      post.message.try(:plain_text_without_markdown) || post_page_title(post)
    else
      I18n.translate 'notifier.a_post_you_shared'
    end
  end

  # @param comment [Comment] The comment to process.
  # @return [String] The formatted comment.
  def comment_message(comment, opts={})
    if comment.post.public?
      comment.message.plain_text_without_markdown
    else
      I18n.translate 'notifier.a_limited_post_comment'
    end
  end
end
